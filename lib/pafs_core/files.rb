# frozen_string_literal: true
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

    def generate_fcerm1(project, format)
      builder = PafsCore::SpreadsheetBuilderService.new
      builder.send("generate_#{format}", [project])
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

    def storage
      @storage ||= if Rails.env.development?
                     PafsCore::DevelopmentFileStorageService.new
                   else
                     PafsCore::FileStorageService.new
                   end
    end
  end
end
