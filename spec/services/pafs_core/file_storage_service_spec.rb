# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FileStorageService do
  let(:storage) { double("storage") }
  let(:antivirus) { double("antivirus") }
  let(:src_file) { "/tmp/from/file.tmp" }
  let(:dst_file) { "1-2-3-4/1/file.xls" }

  describe "#upload" do
    context "given a virus free file" do
      it "virus checks the requested file then puts into storage" do
        expect(antivirus).to receive(:scan).with(src_file) { true }
        expect(storage).to receive(:put_object)
        expect(Aws::S3::Client).to receive(:new) { storage }
        expect(PafsCore::AntivirusService).to receive(:new) { antivirus }
        expect(File).to receive(:open).with(src_file)

        expect { subject.upload(src_file, dst_file) }.not_to raise_error
      end
    end
    context "given an infected file" do
      it "virus checks the file, raises an error and does not store the file" do
        expect(antivirus).to receive(:scan).with(src_file) do
          raise PafsCore::VirusFoundError.new(src_file, "Evil_WiGwAm")
        end
        expect(storage).not_to receive(:put_object)
        expect(Aws::S3::Client).not_to receive(:new) { storage }
        expect(PafsCore::AntivirusService).to receive(:new) { antivirus }

        expect { subject.upload(src_file, dst_file) }.to raise_error PafsCore::VirusFoundError
      end
    end
  end

  describe "#download" do
    context "given a valid source file key" do
      it "gets the requested file from storage" do
        expect(storage).to receive(:get_object).
          with(bucket: nil, key: dst_file, response_target: src_file)
        expect(Aws::S3::Client).to receive(:new) { storage }
        expect { subject.download(dst_file, src_file) }.not_to raise_error
      end
    end
    context "given an invalid source file key" do
      it "raises an error" do
        expect(storage).to receive(:get_object) do
          raise Aws::S3::Errors::NoSuchKey.new("context", "Not there")
        end
        expect(Aws::S3::Client).to receive(:new) { storage }

        expect { subject.download("not_there", dst_file) }.
          to raise_error PafsCore::FileNotFoundError
      end
    end
  end

  describe "#delete" do
    it "deletes the requested file from storage" do
      expect(storage).to receive(:delete_object).with(bucket: nil, key: dst_file)
      expect(Aws::S3::Client).to receive(:new) { storage }
      expect { subject.delete(dst_file) }.not_to raise_error
    end
  end
end
