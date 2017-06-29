# frozen_string_literal: true
# require "rubyXL"
require "roo"

module PafsCore
  class ProgramUploadService
    include PafsCore::Fcerm1, PafsCore::FileTypes, PafsCore::Files

    attr_accessor :user, :errors

    def initialize(user = nil)
      @user = user
    end

    def find(id)
      PafsCore::ProgramUpload.find(id)
    end

    def upload(params = {})
      record = PafsCore::ProgramUpload.new(number_of_records: 0,
                                           status: "new",
                                           reset_consented_flag: params.fetch(:reset_consented_flag, false))

      form_file = params.fetch(:program_upload_file, nil)
      if form_file
        if valid_program_upload_file?(form_file.original_filename)
          begin
            # virus check and upload to S3
            filename = File.basename(form_file.original_filename)
            dest_file = File.join(storage_path, filename)
            storage.upload(form_file.tempfile.path, dest_file)
            record.filename = dest_file
            record.processing_state.upload!
          rescue PafsCore::VirusFoundError, PafsCore::VirusScannerError => e
            record.errors.add(:base, e.message)
          end
        else
          record.errors.add(:base, "This file type is not supported. Please upload "\
                            "the annual refresh FCERM1 Excel file (.xlsx)")
        end
      else
        record.errors.add(:base, "Select a program refresh FCERM1 Excel file "\
                          "(.xlsx) to import")
      end
      record
    end

    # this will take some time and needs to be in a background job
    def process_spreadsheet(upload_record)
      upload_record.processing_state.process!

      begin
        xlsx = fetch_workbook(upload_record.filename)
        row_count = 0

        # clear all consented flags
        PafsCore::Project.update_all(consented: false) if upload_record.reset_consented_flag?

        # Roo has an odd offset so we have to take 2 off our zero-based
        # FIRST_DATA_ROW value
        xlsx.each_row_streaming(pad_cells: true,
                                offset: FIRST_DATA_ROW - 1) do |row|
          next if row.nil? || row[0].blank?
          reset_errors
          row_count += 1
          project = build_project_from_row(row)
          item = create_upload_item(upload_record, project)

          if project.valid?
            # we need to ensure a couple of things are set up
            # project_type
            p = navigator.build_project_step(project, :project_type, nil)
            copy_project_errors(p) if p.invalid?

            # prpject_end_financial_year is needed for tables
            calc_financial_year_for(project) if project.project_end_financial_year.nil?
            # check if we need to set :improve_hpi
            project.improve_hpi = (project.create_habitat_amount.present? &&
                                   project.create_habitat_amount > 0 &&
                                   !(project.improve_spa_or_sac? ||
                                     project.improve_sssi?))

            # do further validations
            validation_steps(project) do |step|
              copy_project_errors(step, true) if step.invalid?
            end

            # any errors should be here
            create_failures_from_errors(item)

            # update record to indicate we've visited funding_sources section
            project.funding_sources_visited = project.funding_values.count.positive?
            project.save
          else
            # An issue with the project reference number
            # So we create failure record and don't save the project
            copy_project_errors(project)
            create_failures_from_errors(item)
          end

          upload_record.number_of_records = row_count
          upload_record.save
        end
        upload_record.number_of_records = row_count
        upload_record.save
        upload_record.processing_state.complete!
      rescue StandardError => exc
        upload_record.processing_state.error!
        Airbrake.notify(exc) if defined? Airbrake
        raise
      end
    end

    def build_project_from_row(row)
      # column "A" (0) is the reference_number
      project = find_or_create_project(row[0].value.upcase)
      return project unless project.valid?

      FCERM1_COLUMN_MAP.each do |col|
        if col.fetch(:import, true)
          range = col.fetch(:date_range, false)
          name = col[:field_name]
          column = column_index col[:column]

          if range
            # handle ranges
            start_column = column
            years = [-1].concat((2015..2027).to_a)
            values = []
            years.each_with_index do |_year, i|
              cell = row[start_column + i]
              values << if cell && cell.value.present?
                          cell.value.to_i
                        else
                          0
                        end
            end
            project.send("#{name}=", values)
          else
            cell = row[column]
            project.send("#{name}=", cell && cell.value)
          end
        end
      end
      project
    end

    def reset_errors
      @errors = {}
    end

    def errors
      @errors ||= {}
    end

  private
    def storage_path
      @storage_path ||= File.join("program_upload",
                                  Time.current.strftime("%Y-%m-%d_%H-%M-%S_%L"))
    end

    def find_or_create_project(ref_no)
      PafsCore::ImportedProjectDecorator.new(
        PafsCore::Project.find_or_create_by(reference_number: ref_no) do |p|
          p.version = 1
          p.creator = user
        end)
    end

    def fetch_workbook(filename)
      temp_file = fetch_file(filename)
      Roo::Spreadsheet.open(temp_file, extension: :xlsx)
    end

    def create_upload_item(upload_record, project)
      ref = if project.invalid? && project.errors[:reference_number].present?
              "Invalid-#{project.reference_number}-(#{SecureRandom.hex})"
            else
              project.reference_number
            end

      upload_record.program_upload_items.create(reference_number: ref,
                                                imported: project.valid?)
    end

    def validation_steps(project)
      step = navigator.first_step

      loop do
        p = navigator.build_project_step(project, step, nil)
        yield p if block_given?
        loop do
          step = navigator.next_step_raw(step, p)
          # :summary_12 is as far as we want to go
          break if step == :summary_12
          next if step.to_s.start_with? "benefit_area_file"
          next if step.to_s.start_with? "summary_"
          break
        end
        break if step == :summary_12
      end
    end

    def calc_financial_year_for(project)
      if project.project_end_financial_year.nil?
        # we need to set one
        fix_financial_year(project)
      else
        # validate
        p = navigator.build_project_step(project, :financial_year, nil)
        if p.invalid?
          copy_project_errors(p)
          fix_financial_year(project)
        end
      end
    end

    def fix_financial_year(project)
      # need to make the financial year equal the last year of spend if possible
      # this might need to be manually corrected by the RMA but we need something
      # otherwise tables etc. break without it.
      project.project_end_financial_year = project.funding_values.maximum(:financial_year) || 2027
    end

    def copy_project_errors(project, clear_attrs_with_errors = false)
      project.errors.keys.each do |key|
        errors[key] = trimmed_error_messages(project.errors.full_messages_for(key)).join("|")
        project.send("#{key}=", nil) if clear_attrs_with_errors &&
                                        project.respond_to?("#{key}=")
      end
    end

    def trimmed_error_messages(list)
      list.map { |m| error_trim(m) }
    end

    def error_trim(message)
      message.split("^").last if message
    end

    def create_failures_from_errors(item)
      errors.each do |k, v|
        item.program_upload_failures.
          create(field_name: k, messages: v)
      end
    end

    def navigator
      @navigator ||= PafsCore::ProjectNavigator.new(nil)
    end
  end
end
