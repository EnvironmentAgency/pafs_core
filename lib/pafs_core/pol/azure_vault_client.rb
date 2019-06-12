# frozen_string_literal: true

module PafsCore::Pol
  class AzureVaultClient
    include AzureOauth

    class VaultReadFailure < StandardError
      def initialize(key_name, status, body)
        @key_name = key_name
        @status = status
        @body = body

        super(message)
      end

      def message
        "Error reading key #{@key_name} from vault [#{@status}] #{@body}"
      end
    end

    def self.fetch(key_name)
      new(key_name: key_name).value
    end

    attr_reader :key_name

    def initialize(key_name:)
      @key_name = key_name
    end

    def value
      raise VaultReadFailure.new(key_name, result.status, result.body) unless success?

      JSON.parse(result.body).fetch('value')
    end

    def success?
      result.status.in?(200..299)
    end

    def result
      @result ||= connection.get key_url
    end

    def connection
      @connection ||= ::Faraday.new(
        headers: headers
      )
    end

    def headers
      {
        'Content-Type' => "application/x-www-form-urlencoded",
        'Authorization' => "Bearer #{bearer_token}"
      }
    end

    def key_url
      @key_url ||= "%{vault_url}/secrets/%{secret_name}?api-version=2016-10-01" % {
        vault_url: vault_url,
        secret_name: key_name
      }
    end

    def vault_url
      @vault_url ||= ENV.fetch('AZURE_VAULT_HOST')
    end
  end
end
