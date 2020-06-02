# frozen_string_literal: true

require "fileutils"

# This is a local file replacement for AWS storage only to
# be used in development
module PafsCore
  class DevelopmentFileStorageService
    attr_reader :user

    def initialize(user = nil)
      @user = user
    end

    def upload(from_path, to_path)
      dest = file_path(to_path)
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(from_path, dest)
    rescue StandardError
      raise PafsCore::FileNotFoundError, "Storage file not found: #{from_path}"
    end

    def upload_data(io_object, to_path)
      dest = file_path(to_path)
      FileUtils.mkdir_p(File.dirname(dest))
      File.open(dest, "wb") { |f| f.write(io_object) }
    rescue StandardError => e
      raise PafsCore::FileNotFoundError, "Something went wrong: #{dest}\n#{e}"
    end

    def download(file_key, dest)
      raise PafsCore::FileNotFoundError, "Storage file not found: #{file_key}" unless exists?(file_key)

      FileUtils.cp(file_path(file_key), dest)
    end

    def delete(file_key)
      raise PafsCore::FileNotFoundError, "Storage file not found: #{file_key}" unless exists?(file_key)

      FileUtils.rm(file_path(file_key))
    end

    def exists?(file_key)
      File.exist? file_path(file_key)
    end

    def expiring_url_for(file_key, _filename)
      return unless exists?(file_key)

      "file://#{file_path(file_key)}"
    end

    private

    def file_path(path)
      Rails.root.join("tmp", path)
    end
  end
end
