# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Pol::AzureOauth::Client do
  let(:endpoint) { "https://example.com/oauth/token" }
  let(:request_payload) do
    {
      grant_type: "client_credentials",
      client_id: "CLIENT_ID",
      client_secret: "CLIENT_SECRET",
      scope: "https://vault.azure.net/.default"
    }.as_json
  end

  around do |example|
    ClimateControl.modify(
      AZURE_OAUTH_URL: 'https://example.com/oauth/token',
      AZURE_CLIENT_ID: 'CLIENT_ID',
      AZURE_CLIENT_SECRET: 'CLIENT_SECRET'
    ) do 
      example.run
    end
  end

  context 'with a successful response from the server' do
    before do
      stub_request(:post, endpoint).with(body: request_payload).to_return(body: {
        access_token: 'A TEST TOKEN'
      }.to_json)
    end

    it 'returns the bearer token' do
      expect(described_class.bearer_token).to eql('A TEST TOKEN')
    end
  end

  context 'with a failure response' do
    before do
      stub_request(:post, endpoint).with(body: request_payload).to_return(status: 401)
    end

    it 'raises an exception with the error code and response' do
      expect do
        described_class.bearer_token
      end.to raise_exception(PafsCore::Pol::AzureOauth::OAuthError)
    end
  end
end

