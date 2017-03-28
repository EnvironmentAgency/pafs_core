# frozen_string_literal: true
module PafsCore
  class FundingCalculatorStep < BasicStep
    include PafsCore::FileTypes, PafsCore::FileStorage
    delegate :funding_calculator_file_name, :funding_calculator_file_name=,
             :funding_calculator_content_type, :funding_calculator_content_type=,
             :funding_calculator_file_size, :funding_calculator_file_size=,
             :funding_calculator_updated_at, :funding_calculator_updated_at=,
             :storage_path,
             to: :project

    attr_reader :funding_calculator
    attr_accessor :virus_info
    validate :virus_free_funding_calculator_present

    def update(params)
      if params.fetch(:commit, nil) == "Continue"
        true
      else
        uploaded_file = step_params(params).fetch(:funding_calculator, nil)
        if uploaded_file
          return false unless filetype_valid?(uploaded_file)
          begin
            old_file = funding_calculator_file_name
            # virus check and upload to S3
            filename = File.basename(uploaded_file.original_filename)
            dest_file = File.join(storage_path, filename)
            storage.upload(uploaded_file.tempfile.path, dest_file)
            PafsCore::CalculatorParserService.new.parse(uploaded_file, project)

            if old_file && old_file != filename
              # aws doesn't raise an error if it cannot find the key when deleting
              storage.delete(File.join(storage_path, old_file))
            end

            self.funding_calculator_file_name = filename
            self.funding_calculator_content_type = uploaded_file.content_type
            self.funding_calculator_file_size = uploaded_file.size
            self.funding_calculator_updated_at = Time.zone.now
            self.virus_info = nil
          rescue PafsCore::VirusFoundError, PafsCore::VirusScannerError => e
            self.virus_info = e.message
          end
        end
        valid? && project.save
      end
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:funding_calculator_step).
        permit(:funding_calculator)
    end

    # NOTE: we could probably check the content type of the file but we are
    # expecting a .xslx file to be uploaded
    def filetype_valid?(file)
      return true if valid_funding_calculator_file?(file.original_filename)

      errors.add(:base, I18n.t("unsupported_funding_calc_format"))
      false
    end

    def virus_free_funding_calculator_present
      if virus_info.present?
        Rails.logger.error virus_info
        errors.add(:base, "The file was rejected because it may contain a virus. Check the file and try again")
      elsif funding_calculator_file_name.blank?
        errors.add(:base, "Upload the completed partnership funding calculator .xslx file")
      end
    end
  end
end
