# frozen_string_literal: true

require 'faraday'

module PafsCore
  module Pol
    class Submission
      def self.perform(project)
        new(project).perform
      end

      attr_reader :project

      def initialize(project)
        @project = project
      end

      def perform
        return unless submission_enabled?
        return unless success?

        project.update_column(:submitted_to_pol, Time.now.utc)
      end

      private

      def result
        @result ||= connection.post do |request|
          request.headers['Content-Type'] = 'application/json'
          request.headers['x-function-key'] = api_token
          request.body = payload
        end
      end

      def success?
        result.status.in?(200..299)
      end

      def json_presenter
        @json_presenter ||= PafsCore::Camc3Presenter.new(project: project)
      end

      def payload
        @payload ||= json_presenter.attributes.to_json
      end

      def url
        ENV.fetch('POL_SUBMISSION_URL', '').strip
      end

      def api_token
        PafsCore::Pol::AzureVaultClient.fetch(
          ENV.fetch('AZURE_VAULT_AUTH_TOKEN_KEY_NAME_SUBMISSION')
        )
      end

      def connection
        Faraday.new(url: url) do |faraday|
          faraday.adapter Faraday.default_adapter
        end
      end

      def submission_enabled?
        !url.blank?
      end
    end
  end
end
