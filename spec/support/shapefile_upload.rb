module ShapefileUpload
  class Upload
    include PafsCore::FileStorage

    attr_reader :project, :fixture_file_name

    def initialize(project, fixture_file_name)
      @project = project
      @fixture_file_name = fixture_file_name
    end

    def uploaded_file
      @uploaded_file ||= Rack::Test::UploadedFile.new(
        File.open(
          File.join(Rails.root, '..', 'fixtures', fixture_file_name)
        )
      )
    end

    def data
      uploaded_file.read
    end

    def filename
      File.basename(uploaded_file.original_filename)
    end

    def destination
      File.join(project.storage_path, filename)
    end

    def perform
      storage.upload(uploaded_file, destination)

      project.update_columns(
        benefit_area_file_name: filename,
        benefit_area_content_type: uploaded_file.content_type,
        benefit_area_file_size: uploaded_file.size,
        benefit_area_file_updated_at: Time.zone.now
      )
    end
  end
end
