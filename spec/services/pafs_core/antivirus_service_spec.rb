# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::AntivirusService do
  let(:clamav) { double("clamav") }

  describe "#service_available?" do
    context "when virus service unavailable" do
      it "returns false" do
        expect(clamav).to receive(:execute) { false }
        expect(ClamAV::Client).to receive(:new) { clamav }
        expect(subject.service_available?).to be false
      end
    end

    context "when the virus service is available" do
      it "returns true" do
        expect(clamav).to receive(:execute) { true }
        expect(ClamAV::Client).to receive(:new) { clamav }
        expect(subject.service_available?).to be true
      end
    end
  end

  describe "#scan" do
    context "when a virus is found" do
      it "raises a PafsCore::VirusFoundError" do
        expect(clamav).to receive(:execute) { [FactoryBot.build(:virus_found)] }
        expect(ClamAV::Client).to receive(:new) { clamav }
        expect { subject.scan("path/to/suspect_file.xls") }.to raise_error PafsCore::VirusFoundError
      end
    end

    context "when the virus scanner generates an error" do
      it "raises a PafsCore::VirusScannerError" do
        expect(clamav).to receive(:execute) { [FactoryBot.build(:virus_error)] }
        expect(ClamAV::Client).to receive(:new) { clamav }
        expect { subject.scan("path/to/file") }.to raise_error PafsCore::VirusScannerError
      end
    end

    context "when no virii are found" do
      it "returns true" do
        expect(clamav).to receive(:execute) { [FactoryBot.build(:virus_clear)] }
        expect(ClamAV::Client).to receive(:new) { clamav }
        expect(subject.scan("path/to/a/clean_file")).to eq true
      end
    end
  end
end
