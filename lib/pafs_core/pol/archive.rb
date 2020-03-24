# frozen_string_literal: true

require "faraday"

module PafsCore
  module Pol
    class Archive
      def self.perform(project)
        new(project).perform
      end

      attr_reader :project

      def initialize(project)
        @project = project
      end

      def status
        result.status
      end

      def response
        result.body
      end

      def perform
        return unless enabled?

        success?
      end

      private

      def result
        @result ||= connection.put do |request|
          request.headers["Content-Type"] = "application/json"
          request.headers["x-functions-key"] = api_token
          request.body = payload
        end
      end

      def success?
        result.status.in?(200..299)
      end

      def payload
        @payload ||= {
          "NPN": project.reference_number,
          "Status": "Archived"
        }.to_json
      end

      def url
        ENV.fetch("POL_ARCHIVE_URL", "").strip
      end

      def api_token
        PafsCore::Pol::AzureVaultClient.fetch(
          ENV.fetch("AZURE_VAULT_AUTH_TOKEN_KEY_NAME_SUBMISSION")
        )
      end

      def connection
        Faraday.new(url: url) do |faraday|
          faraday.adapter Faraday.default_adapter
        end
      end

      def enabled?
        !url.blank?
      end
    end
  end
end
