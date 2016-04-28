# frozen_string_literal: true
require "aws-sdk"

module PafsCore
  class FileStorageService
    attr_reader :user

    def initialize(user = nil)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def upload(from_path, to_path)
      antivirus.scan(from_path)
      storage.put_object(bucket: bucket_name, key: to_path, body: File.open(from_path))
    end

    # dest can be a file name or IO
    # eg
    # t = Tempfile.new
    # fss.download("my_file_key", t)
    # t.rewind
    # # ... do stuff
    # t.close!
    # although seems to work more reliably under rails as a file name
    # eg
    # t = TempFile.new
    # fss.download("my_file_key", t.path)
    # t.rewind
    # # ...
    # t.close!
    def download(file_key, dest)
      storage.get_object(bucket: bucket_name, key: file_key, response_target: dest)
    end

    def delete(file_key)
      storage.delete_object(bucket: bucket_name, key: file_key)
    end

  private
    def antivirus
      PafsCore::AntivirusService.new user
    end

    def storage
      @storage ||= Aws::S3::Client.new(region: "eu-west-1", credentials: credentials)
    end

    def credentials
      Aws::Credentials.new(aws_access_key, aws_secret_key)
    end

    def aws_access_key
      ENV["FILE_UPLOAD_ACCESS_KEY"]
    end

    def aws_secret_key
      ENV["FILE_UPLOAD_SECRET_KEY"]
    end

    def bucket_name
      ENV["FILE_UPLOAD_BUCKET"]
    end
  end
end
