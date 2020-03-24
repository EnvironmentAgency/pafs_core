# frozen_string_literal: true

module PafsCore
  class BenefitAreaFileStep < BasicStep
    include PafsCore::FileStorage
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
            antivirus.scan(uploaded_file.tempfile.path)
            return false unless contins_required_gis_files(uploaded_file)

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

    private

    def antivirus
      PafsCore::AntivirusService.new user
    end

    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:benefit_area_file_step)
                                  .permit(:benefit_area_file)
    end

    EXPECTED_EXTENSIONS = %w[dbf shx shp prj].freeze

    def contins_required_gis_files(uploaded_file)
      Zip::File.open(uploaded_file.tempfile.path) do |zip_file|
        entries = zip_file.entries.map(&:name)

        EXPECTED_EXTENSIONS.each do |ext|
          next if entries.select { |entry| entry.match(/\.#{ext}$/) }.any?

          errors.add(:base, "The selected file must be a zip file, containing the following mandatory files: dbf. shx. shp. prj.")
          return false
        end
      end

      true
    rescue Zip::Error
      errors.add(:base, "The selected file must be a zip file, containing the following mandatory files: dbf. shx. shp. prj.")
      false
    end

    def filetype_valid?(file)
      return true if valid_benefit_area_file?(file.original_filename)

      errors.add(:base, "The selected file must be a zip file, containing the following mandatory files: dbf. shx. shp. prj.")
      false
    end

    def virus_free_benefit_area_present
      if virus_info.present?
        Rails.logger.error virus_info
        errors.add(:base, "The file was rejected because it may contain a virus. "\
                          "Check the file and try again")
      elsif benefit_area_file_name.blank?
        errors.add(:base, "Upload a shapefile that outlines "\
                          "the area the project is likely to benefit")
      end
    end
  end
end
