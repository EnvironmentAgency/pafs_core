# frozen_string_literal: true

require "rails_helper"

describe PafsCore::Pol::Submission, :vcr do
  let(:perform) { described_class.perform(project) }
  let(:project) { create(:project) }

  let(:url) { "https://example.com/test" }
  let!(:post_request) { stub_request(:post, "https://example.com/test") }
  let(:json_serializer) { double(:json_serializer, attributes: { test: "value" }) }

  before do
    allow(PafsCore::Camc3Presenter).to receive(:new).with(
      project: project
    ).and_return(json_serializer)

    allow(PafsCore::Pol::AzureVaultClient).to receive(:fetch).with("KEY_NAME").and_return("APITOKEN")
  end

  around do |example|
    ClimateControl.modify(
      POL_SUBMISSION_URL: url,
      AZURE_VAULT_AUTH_TOKEN_KEY_NAME_SUBMISSION: "KEY_NAME"
    ) do
      example.run
    end
  end

  context "with no POL_SUBMISSION_URL" do
    let(:url) { "" }

    it "does not send anything to POL" do
      perform
      expect(post_request).not_to have_been_requested
    end

    it "does not raise an error" do
      expect do
        perform
      end.not_to raise_exception
    end
  end

  context "with a POL_SUBMISSION_URL" do
    it "submits the project to the correct URL" do
      perform
      expect(post_request).to have_been_requested.once
    end

    it "encodes the project correctly" do
      perform
      expect(post_request.with(
               body: '{"test":"value"}'
             )).to have_been_requested.once
    end

    it "sets the content type header" do
      perform
      expect(post_request.with(
               headers: { "Content-Type" => "application/json" }
             )).to have_been_requested.once
    end

    it "sets the api token header" do
      perform
      expect(post_request.with(
               headers: { "x-functions-key" => "APITOKEN" }
             )).to have_been_requested.once
    end

    it "does not raise an error" do
      expect do
        perform
      end.not_to raise_exception
    end

    context "on successful submission" do
      before do
        stub_request(:post, "https://example.com/test").to_return(status: 200)
      end

      it "changes the submitted_to_pol timestamp" do
        expect do
          perform
        end.to change { project.reload.submitted_to_pol }
      end
    end

    context "on unsuccessful submission" do
      before do
        stub_request(:post, "https://example.com/test").to_return(status: 401)
      end

      it "does not change the submitted_to_pol timestamp" do
        expect do
          perform
        end.not_to change { project.reload.submitted_to_pol }
      end

      it "does not raise an exception" do
        expect do
          perform
        end.not_to raise_exception
      end
    end
  end
end
