# frozen_string_literal: true

require "aws-sdk-s3"

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
      # storage.put_object(bucket: bucket_name, key: to_path, body: File.open(from_path))
      upload_data(File.open(from_path), to_path)
    end

    def upload_data(io_object, to_path)
      # NOTE: NO VIRUS CHECK HERE - only use this for in-memory generated documents
      # or files that have already been scanned
      storage.put_object(bucket: bucket_name, key: to_path, body: io_object)
    end

    def download(file_key, dest)
      storage.get_object(bucket: bucket_name, key: file_key, response_target: dest)
    rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
      raise PafsCore::FileNotFoundError, "Storage file not found: #{file_key}"
    end

    def delete(file_key)
      # NOTE: this doesn't raise a S3 error if the key is not found
      storage.delete_object(bucket: bucket_name, key: file_key)
    end

    def exists?(file_key)
      storage.head_object(bucket: bucket_name, key: file_key)
      true
    rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
      false
    end

    def expiring_url_for(file_key, filename = nil)
      return unless exists?(file_key)

      filename ||= File.basename(file_key)

      Aws::S3::Object.new(
        bucket_name,
        file_key,
        region: "eu-west-1",
        credentials: credentials
      ).presigned_url(:get, expires_in: 60, response_content_disposition: "attachment; filename=#{filename}")
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
