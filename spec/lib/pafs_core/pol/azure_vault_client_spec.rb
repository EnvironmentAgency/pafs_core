# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Pol::AzureVaultClient do
  let(:headers) do
    {
      'Content-Type' => "application/x-www-form-urlencoded",
      'Authorization' => "Bearer ACCESS_TOKEN"
    }
  end

  let(:endpoint) { "https://example.com" }

  before do
    allow(PafsCore::Pol::AzureOauth::Client).to receive(:bearer_token).and_return("ACCESS_TOKEN")

    stub_request(:get, "#{endpoint}/secrets/VALID_KEY?api-version=2016-10-01").with(headers: headers).to_return(body: {
      "value"=>"VALID KEY VALUE",
      "id"=>"https://pol-pafs-integration.vault.azure.net/secrets/POLTest2/fd21aa10872e4ebca4a40830217d1959",
      "attributes"=>{
        "enabled"=>true,
        "created"=>1560791472,
        "updated"=>1560791472,
        "recoveryLevel"=>"Purgeable"
      }
    }.to_json)

    stub_request(:get, "#{endpoint}/secrets/INVALID_KEY?api-version=2016-10-01").to_return(status: 401)
  end

  around do |example|
    ClimateControl.modify(
      AZURE_VAULT_HOST: endpoint
    ) do
      example.run
    end
  end


  context 'with a valid request' do
    it 'returns the key value' do
      expect(described_class.fetch('VALID_KEY')).to eql("VALID KEY VALUE")
    end
  end

  context 'with an invalid request' do
    it 'raises an exception' do
      expect do
        described_class.fetch('INVALID_KEY')
      end.to raise_exception(PafsCore::Pol::AzureVaultClient::VaultReadFailure)
    end
  end
end
