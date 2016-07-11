# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FundingCalculatorStep, type: :model do
  before(:all) { @tempfile = Tempfile.new }
  after(:all) { @tempfile.close! }

  describe "attributes" do
    subject { FactoryGirl.build(:funding_calculator_step) }

    it_behaves_like "a project step"

    it "validates that a file has been selected" do
      subject.funding_calculator_file_name = nil
      expect(subject.valid?).to eq false
      expect(subject.errors[:base]).to include "Select your partnership funding calculator file"
    end

    it "validates that the file passed a virus check" do
      subject.virus_info = "Found a nasty virus"
      expect(subject.valid?).to eq false
      expect(subject.errors[:base]).
        to include "The file was rejected because it may contain a virus. Verify your file and try again"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:funding_calculator_step) }
    let(:filename) { "new_file.xls" }
    let(:content_type) { "text/plain" }
    let(:temp_file) do
      ActionDispatch::Http::UploadedFile.new(tempfile: @tempfile,
                                             filename: filename.dup,
                                             type: content_type)
    end
    let(:params) do
      HashWithIndifferentAccess.new(
        { funding_calculator_step: { funding_calculator: temp_file }}
      )
    end
    let(:empty_params) do
      HashWithIndifferentAccess.new(
        { funding_calculator_step: { funding_calculator_file_name: "placeholder" }}
      )
    end
    let(:continue_params) { { commit: "Continue" } }

    context "when 'Continue' button selected" do
      it "updates step to :summary" do
        subject.update(continue_params)
        expect(subject.step).to eq :summary
      end

      it "returns true" do
        expect(subject.update(continue_params)).to eq true
      end
    end

    context "when a virus free file is selected" do
      let(:storage) { double("storage") }
      before(:each) do
        expect(PafsCore::FileStorageService).to receive(:new) { storage }
        expect(storage).to receive(:upload) { true }
        subject.funding_calculator_file_name = nil
      end

      it "uploads the file" do
        expect(subject.update(params)).to eq true
      end

      it "saves the file details" do
        subject.update(params)
        expect(subject.funding_calculator_file_name).to eq filename
        expect(subject.funding_calculator_content_type).to eq content_type
        expect(subject.funding_calculator_file_size).to eq @tempfile.size
        expect(subject.funding_calculator_updated_at).to be_within(1.second).of(Time.zone.now)
      end

      it "points to the next step in the chain" do
        expect { subject.update(params) }.to change { subject.step }
      end

      it "returns true" do
        expect(subject.update(params)).to eq true
      end

      context "when an uploaded file already exists" do
        let(:new_file) { "my_file.xls" }
        it "deletes the previous file" do
          subject.funding_calculator_file_name = new_file
          expect(storage).to receive(:delete).with(File.join(subject.storage_path, new_file)) { true }
          expect(subject.update(params)).to eq true
        end
      end
    end

    context "when a valid file has already been uploaded" do
      it "returns true when no new file is selected" do
        expect(subject.update(empty_params)).to eq true
      end
    end

    context "when a virus infected file is selected" do
      let(:storage) { double("storage") }
      before(:each) do
        expect(PafsCore::FileStorageService).to receive(:new) { storage }
        expect(storage).to receive(:upload) do
          raise PafsCore::VirusFoundError.new(@tempfile.path, "nAsTyVirus")
        end
      end

      it "does not save the file details" do
        expect { subject.update(params) }.not_to change { subject.funding_calculator_file_name }
      end

      it "returns false" do
        expect(subject.update(params)).to eq false
      end

      it "does not change the next step" do
        expect { subject.update(params) }.not_to change { subject.step }
      end
    end

    context "when a virus scanner issue prevented the file from being scanned" do
      let(:storage) { double("storage") }
      before(:each) do
        expect(PafsCore::FileStorageService).to receive(:new) { storage }
        expect(storage).to receive(:upload) do
          raise PafsCore::VirusScannerError.new("A problem occurred")
        end
      end

      it "does not save the file details" do
        expect { subject.update(params) }.not_to change { subject.funding_calculator_file_name }
      end

      it "returns false" do
        expect(subject.update(params)).to eq false
      end

      it "does not change the next step" do
        expect { subject.update(params) }.not_to change { subject.step }
      end
    end
  end

  describe "#download" do
    let(:storage) { double("storage") }
    subject { FactoryGirl.build(:funding_calculator_step) }
    before(:each) do
      @upload_path = File.join(subject.storage_path, subject.funding_calculator_file_name)
      expect(PafsCore::FileStorageService).to receive(:new) { storage }
    end

    context "when an uploaded file exists" do
      let(:tmpfile) { double("tmpfile") }
      before(:each) do
        expect(storage).to receive(:download)
        expect(Tempfile).to receive(:new) { tmpfile }
        expect(tmpfile).to receive(:path) { "path/to/file.xls" }
        expect(tmpfile).to receive(:rewind) { 0 }
      end

      it "returns a temporary file" do
        expect(subject.download).to eq tmpfile
      end

      context "when a block is given" do
        let(:tmpfile_content) { "Wigwam haystack" }
        it "passes the temporary file data and details to the block" do
          expect(tmpfile).to receive(:read) { tmpfile_content }
          expect(tmpfile).to receive(:close!)

          expect { |b| subject.download(&b) }.
            to yield_with_args(tmpfile_content,
                            subject.funding_calculator_file_name,
                            subject.funding_calculator_content_type)
        end
      end
    end
  end

  describe "#delete_calculator" do
    let(:storage) { double("storage") }
    subject { FactoryGirl.build(:funding_calculator_step) }
    before(:each) do
      expect(PafsCore::FileStorageService).to receive(:new) { storage }
    end

    context "when an uploaded file exists" do
      it "removes the file from storage" do
        expect(storage).to receive(:delete)
        subject.delete_calculator
      end

      it "resets the stored file attributes" do
        expect(storage).to receive(:delete)
        subject.delete_calculator
        expect(subject.funding_calculator_file_name).to be_nil
        expect(subject.funding_calculator_content_type).to be_nil
        expect(subject.funding_calculator_file_size).to be_nil
        expect(subject.funding_calculator_updated_at).to be_nil
        expect(subject.virus_info).to be_nil
      end
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:funding_calculator_step) }

    it "should return :urgency" do
      expect(subject.previous_step).to eq :urgency
    end
  end
end
