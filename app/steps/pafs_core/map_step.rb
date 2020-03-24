# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class MapStep < BasicStep
    include PafsCore::FileTypes
    delegate :benefit_area=,
             :benefit_area_zoom_level, :benefit_area_zoom_level=,
             :benefit_area_centre=,
             :project_location, :project_location?, :project_location_zoom_level,
             :benefit_area_file_name, :benefit_area_file_name=,
             :benefit_area_content_type, :benefit_area_content_type=,
             :benefit_area_file_size, :benefit_area_file_size=,
             :benefit_area_file_updated_at, :benefit_area_file_updated_at=,
             :benefit_area?, :benefit_area_file_name?, :storage_path,
             to: :project

    attr_reader :benefit_area_file, :map_centre
    attr_accessor :virus_info

    validate :virus_free_benefit_area_file_present, :presence_of_file

    def benefit_area
      project.benefit_area ||= "[[[]]]"
    end

    def benefit_area_centre
      project.benefit_area_centre ||= project_location
    end

    def update(params)
      sp = step_params(params)
      if sp[:benefit_area_file]
        benefit_area_file = sp.fetch(:benefit_area_file)
        if valid_benefit_area_file?(benefit_area_file.original_filename)
          upload_benefit_area_file(benefit_area_file)
        else
          errors.add(:base,
                     I18n.t("unsupported_file_type", formats: benefit_area_file_types))
          return false
        end
      else
        sp[:benefit_area_centre] = JSON.parse(sp[:benefit_area_centre]) unless sp[:benefit_area_centre].nil?
        sp[:benefit_area_zoom_level] = sp[:benefit_area_zoom_level].to_i
        assign_attributes(sp)
      end
      valid? && project.save
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

    def before_view(_params)
      @map_centre = PafsCore::MapService.new
                                        .find(
                                          benefit_area_centre.join(","),
                                          project_location
                                        )
    end

    private

    def presence_of_file
      errors.add(:base, I18n.t("missing_shapefile_error")) if benefit_area_file_name.nil?
    end

    def upload_benefit_area_file(uploaded_file)
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

    def reset_file_attributes
      self.benefit_area_file_name = nil
      self.benefit_area_content_type = nil
      self.benefit_area_file_size = nil
      self.benefit_area_file_updated_at = nil
      self.virus_info = nil
      project.save
    end

    def storage
      @storage ||= if Rails.env.development? || Rails.env.test?
                     PafsCore::DevelopmentFileStorageService.new user
                   else
                     PafsCore::FileStorageService.new user
                   end
    end

    def virus_free_benefit_area_file_present
      if benefit_area_file.present?
        if virus_info.present?
          Rails.logger.error virus_info
          errors.add(:base, "The file was rejected because it may contain a virus. Check the file and try again")
        elsif benefit_area_file_name.blank?
          errors.add(:base, "Upload a file that outlines the area of protection")
        end
      end
    end

    def step_params(params)
      params
        .require(:map_step)
        .permit(:benefit_area,
                :benefit_area_centre,
                :benefit_area_zoom_level,
                :benefit_area_file)
    end
  end
end
