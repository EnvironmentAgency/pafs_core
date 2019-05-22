module PafsCore
  class ShapefileSerializer
    include PafsCore::FileStorage

    def self.serialize(project)
      new(project).serialize
    end

    attr_reader :project

    def initialize(project)
      @project = project
    end

    def serialize
      return nil unless has_shapefile?

      Base64.strict_encode64(shapefile_data)
    end

    private

    def shapefile_temp_file
      @shapefile_temp_file ||= Tempfile.new.tap do |file|
        storage.download(File.join(project.storage_path, project.benefit_area_file_name), file.path)
      end
    end

    def shapefile_data
      @shapefile_data ||= shapefile_temp_file.read
    end

    def has_shapefile?
      project.benefit_area_file_name.present?
    end
  end
end
