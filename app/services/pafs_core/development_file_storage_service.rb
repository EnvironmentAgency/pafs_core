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
      x = FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(from_path, dest)
    rescue StandardError
      raise PafsCore::FileNotFoundError, "Storage file not found: #{from_path}"
    end

    def upload_data(io_object, to_path)
      dest = file_path(to_path)
      x = FileUtils.mkdir_p(File.dirname(dest))
      File.open(dest, "wb") { |f| f.write(io_object) }
    rescue StandardError => e
      raise PafsCore::FileNotFoundError, "Something went wrong: #{dest}\n#{e}"
    end

    def download(file_key, dest)
      if File.exist?(file_path(file_key))
        FileUtils.cp(file_path(file_key), dest)
      else
        raise PafsCore::FileNotFoundError, "Storage file not found: #{file_key}"
      end
    end

    def delete(file_key)
      if File.exist? file_path(file_key)
        FileUtils.rm(file_path(file_key))
      else
        raise PafsCore::FileNotFoundError, "Storage file not found: #{file_key}"
      end
    end

    private

    def file_path(path)
      Rails.root.join("tmp", path)
    end
  end
end
