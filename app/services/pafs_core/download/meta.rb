# frozen_string_literal: true

# When creating some downloads, rather than have a table dedicated to tracking
# the metadata relating to the generation, we can store the metadata next to the
# generated file in the storage service.

module PafsCore
  module Download
    class Meta
      attr_reader :filename

      def initialize(filename:)
        @filename = filename
      end

      def self.load(filename)
        new(filename: filename).tap(&:load)
      end

      def load
        return unless exists?

        unless defined?(@_file_content)
          file = Tempfile.new
          storage.download(filename, file.path)
          file.rewind

          @_file_content = JSON.parse(file.read)
          file.close!
        end

        block_given? ? yield(@_file_content) : @_file_content
      end

      def exists?
        storage.exists? filename
      end

      def create(content)
        storage.upload_data(content.to_json, filename)
      end

      def dev_file_storage?
        Rails.env.test? || Rails.env.development?
      end

      def storage
        @storage ||= dev_file_storage? ? PafsCore::DevelopmentFileStorageService.new : PafsCore::FileStorageService.new
      end
    end
  end
end
