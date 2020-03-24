# frozen_string_literal: true

require "faraday"

module PafsCore::Pol
  module AzureOauth
    class OAuthError < StandardError
      def initialize(status:, body:)
        @status = status
        @body = body

        super(message)
      end

      def message
        "Error authenticating : #{@status}: #{@body.inspect}"
      end
    end

    class Client
      def self.bearer_token
        new.bearer_token
      end

      def bearer_token
        @bearer_token ||= token_response.fetch("access_token")
      end

      def token_response
        raise OAuthError.new(status: result.status, body: result.body) unless success?

        @token_response ||= JSON.parse(result.body)
      end

      def success?
        result.status.in?(200..299)
      end

      def result
        @result ||= connection.post do |request|
          request.body = payload
        end
      end

      def connection
        @connection ||= ::Faraday.new(
          url: auth_url,
          headers: headers
        )
      end

      def headers
        { "Content-Type" => "application/x-www-form-urlencoded" }
      end

      def payload
        {
          "grant_type" => "client_credentials",
          "client_id" => client_id,
          "client_secret" => client_secret,
          "scope" => "https://vault.azure.net/.default"
        }
      end

      def auth_url
        ENV.fetch("AZURE_OAUTH_URL")
      end

      def client_id
        ENV.fetch("AZURE_CLIENT_ID")
      end

      def client_secret
        ENV.fetch("AZURE_CLIENT_SECRET")
      end
    end

    def bearer_token
      @bearer_token ||= Client.bearer_token
    end
  end
end
