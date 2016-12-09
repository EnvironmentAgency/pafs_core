# frozen_string_literal: true
module PafsCore
  class BenefitAreaFileStep < BasicStep
    include PafsCore::FileTypes
    delegate :benefit_area_file_name, :benefit_area_file_name=,
             :benefit_area_content_type, :benefit_area_content_type=,
             :benefit_area_file_size, :benefit_area_file_size=,
             :benefit_area_file_updated_at, :benefit_area_file_updated_at=,
             :storage_path,
             to: :project

    attr_reader :funding_calculator
    attr_accessor :virus_info
    validate :virus_free_benefit_area_present

    def update(params)
      if params.fetch(:commit, nil) == "Continue"
        true
      else
        uploaded_file = step_params(params).fetch(:benefit_area_file, nil)
        if uploaded_file
          return false unless filetype_valid?(uploaded_file)
          begin
            old_file = benefit_area_file_name
            # virus check and upload to S3
            filename = File.basename(uploaded_file.original_filename)
            dest_file = File.join(storage_path, filename)
            storage.upload(uploaded_file.tempfile.path, dest_file)

            if old_file && old_file != filename
              # aws doesn't raise an error if it cannot find the key when deleting
              storage.delete(File.join(storage_path, old_file))
            end

            self.benefit_area_file_name = filename
            self.benefit_area_content_type = uploaded_file.content_type
            self.benefit_area_file_size = uploaded_file.size
            self.benefit_area_file_updated_at = Time.zone.now
            self.virus_info = nil
          rescue PafsCore::VirusFoundError, PafsCore::VirusScannerError => e
            self.virus_info = e.message
          end
        end
        valid? && project.save
      end
    end

    def download
      if benefit_area_file_name.present?
        t = Tempfile.new
        storage.download(File.join(storage_path, benefit_area_file_name), t.path)
        t.rewind

        if block_given?
          yield t.read, benefit_area_file_name, benefit_area_content_type
          t.close!
        else
          t
        end
      end
    end

    def delete_benefit_area_file
      if benefit_area_file_name.present?
        storage.delete(File.join(storage_path, benefit_area_file_name))
        reset_file_attributes
      end
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:benefit_area_file_step).
        permit(:benefit_area_file)
    end

    def reset_file_attributes
      self.benefit_area_file_name = nil
      self.benefit_area_content_type = nil
      self.benefit_area_file_size = nil
      self.benefit_area_file_updated_at = nil
      self.virus_info = nil
      project.save
    end

    def storage
      @storage ||= if Rails.env.development?
                     PafsCore::DevelopmentFileStorageService.new user
                   else
                     PafsCore::FileStorageService.new user
                   end
    end

    def filetype_valid?(file)
      return true if valid_benefit_area_file?(file.original_filename)

      errors.add(:base, "This file type is not supported. Upload a shapefile "\
                        "or an inmage file using one of the following formats: "\
                        "zip, jpg, png, svg or bmp.")
      false
    end

    def virus_free_benefit_area_present
      if virus_info.present?
        Rails.logger.error virus_info
        errors.add(:base, "The file was rejected because it may contain a virus. "\
                          "Verify your file and try again")
      elsif benefit_area_file_name.blank?
        errors.add(:base, "Upload a shapefile or image file that outlines "\
                          "the area the project is likely to benefit")
      end
    end
  end
end
