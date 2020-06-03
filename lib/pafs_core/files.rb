# frozen_string_literal: true

require "zip"

module PafsCore
  module Files
    def fcerm1_filename(reference, format)
      "#{ref_to_file_name(reference)}_FCERM1.#{format}"
    end

    def pfcalc_filename(reference, original_filename)
      "#{ref_to_file_name(reference)}_PFcalculator#{File.extname(original_filename)}"
    end

    def moderation_filename(reference, urgency_code)
      "#{ref_to_file_name(reference)}_moderation_#{urgency_code}.txt"
    end

    def ref_to_file_name(reference)
      reference.parameterize.upcase
    end

    def apt_fcerm1_storage_filename(area)
      "#{apt_storage_path(area.id)}/#{apt_fcerm1_filename}"
    end

    def apt_funding_calculator_filename
      "funding_calculator.zip"
    end

    def apt_fcerm1_filename
      "fcerm1_proposals.xlsx"
    end

    def apt_benefit_areas_storage_filename(area)
      "#{apt_storage_path(area.id)}/#{apt_benefit_areas_filename}"
    end

    def apt_benefit_areas_filename
      "benefit_areas.zip"
    end

    def apt_moderation_storage_filename(area)
      "#{apt_storage_path(area.id)}/#{apt_moderation_filename}"
    end

    def apt_moderation_filename
      "moderations.zip"
    end

    def apt_storage_path(area_id)
      "area_programme/#{area_id}"
    end

    def apt_pf_calculator_filename(area)
      "#{apt_storage_path(area.id)}/#{apt_funding_calculator_filename}"
    end

    def generate_fcerm1(project, format)
      builder = PafsCore::SpreadsheetService.new
      builder.send("generate_#{format}", project)
    end

    def generate_multi_fcerm1(projects, filename)
      puts "Generating"

      xlsx = PafsCore::SpreadsheetService.new.generate_multi_xlsx(projects) do |total_projects, project_index|
        yield(total_projects, project_index) if block_given?
      end

      puts "Generation complete"
      puts "Uploading"
      storage.upload_data(xlsx.stream.read, filename)
      puts "Upload complete"
    end

    def generate_benefit_areas_file(projects, filename)
      tmpfile = Tempfile.new
      # make tmpfile an empty Zipfile
      Zip::OutputStream.open(tmpfile) { |_| }
      # now we can open the temporary zipfile
      Zip::File.open(tmpfile.path, Zip::File::CREATE) do |zf|
        projects.each do |project|
          fetch_benefit_area_file_for(project) do |data, filename, _content_type|
            zf.get_output_stream(filename) { |f| f.write(data) }
          end
        end
      end

      # store file
      storage.upload_data(File.read(tmpfile.path), filename)
    ensure
      tmpfile.close
      tmpfile.unlink
    end

    def generate_proposals_funding_calculator_file(projects, filename)
      tmpfile = Tempfile.new
      # make tmpfile an empty Zipfile
      Zip::OutputStream.open(tmpfile) { |_| }
      # now we can open the temporary zipfile
      Zip::File.open(tmpfile.path, Zip::File::CREATE) do |zf|
        projects.each do |project|
          fetch_funding_calculator_for(project) do |data, project_filename, _content_type|
            zf.get_output_stream(project_filename) { |f| f.write(data) }
          end
        end
      end

      # store file
      storage.upload_data(File.read(tmpfile.path), filename)
    ensure
      tmpfile.close
      tmpfile.unlink
    end

    def generate_moderations_file(projects, filename)
      tmpfile = Tempfile.new
      # make tmpfile an empty Zipfile
      Zip::OutputStream.open(tmpfile) { |_| }
      # now we can open the temporary zipfile
      Zip::File.open(tmpfile.path, Zip::File::CREATE) do |zf|
        projects.each do |project|
          generate_moderation_for(project) do |data, project_filename, _content_type|
            zf.get_output_stream(project_filename) { |f| f.write(data) }
          end
        end
      end

      # store file
      storage.upload_data(File.read(tmpfile.path), filename)
    ensure
      tmpfile.close
      tmpfile.unlink
    end

    # benefit area file
    def make_benefit_area_file_name(reference, original_filename)
      "#{ref_to_file_name(reference)}_benefit_area#{File.extname(original_filename)}"
    end

    def fetch_benefit_area_file_for(project)
      if project.benefit_area_file_name
        t = Tempfile.new
        storage.download(File.join(project.storage_path, project.benefit_area_file_name), t.path)
        t.rewind

        if block_given?
          filename = make_benefit_area_file_name(project.reference_number, project.benefit_area_file_name)
          yield t.read, filename, project.benefit_area_content_type
          t.close!
        else
          t
        end
      end
    end

    def delete_benefit_area_file_for(project)
      if project.benefit_area_file_name
        storage.delete(File.join(project.storage_path, project.benefit_area_file_name))
        project.benefit_area_file_name = nil
        project.benefit_area_content_type = nil
        project.benefit_area_file_size = nil
        project.benefit_area_file_updated_at = nil
        project.save!
      end
    end

    def fetch_funding_calculator_for(project)
      if project.funding_calculator_file_name
        t = Tempfile.new
        storage.download(File.join(project.storage_path, project.funding_calculator_file_name), t.path)
        t.rewind

        if block_given?
          filename = pfcalc_filename(project.reference_number, project.funding_calculator_file_name)
          yield t.read, filename, project.funding_calculator_content_type
          t.close!
        else
          t
        end
      end
    end

    def delete_funding_calculator_for(project)
      if project.funding_calculator_file_name
        storage.delete(File.join(project.storage_path, project.funding_calculator_file_name))
        project.funding_calculator_file_name = nil
        project.funding_calculator_content_type = nil
        project.funding_calculator_file_size = nil
        project.funding_calculator_updated_at = nil
        project.save!
      end
    end

    def generate_moderation_for(project)
      project = PafsCore::ModerationPresenter.new(project)
      if project.urgent?
        t = Tempfile.new
        t.write project.body
        t.rewind

        if block_given?
          yield t.read, moderation_filename(project.reference_number,
                                            project.urgency_code), "text/plain"
          t.close!
        else
          t
        end
      end
    end

    def fetch_file(filename)
      if filename
        t = Tempfile.new
        storage.download(filename, t.path)
        t.rewind

        if block_given?
          yield t.read, filename
          t.close!
        else
          t
        end
      end
    end

    def expiring_url_for(file_key, filename = nil)
      storage.expiring_url_for(file_key, filename)
    end

    def file_exists?(filename)
      storage.exists? filename
    end

    def storage
      @storage ||= if Rails.env.test? || Rails.env.development?
                     PafsCore::DevelopmentFileStorageService.new
                   else
                     PafsCore::FileStorageService.new
                   end
    end
  end
end
