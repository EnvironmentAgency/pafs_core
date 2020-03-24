# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::BenefitAreaFileStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:benefit_area_file_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    subject { FactoryBot.build(:benefit_area_file_step) }

    let(:antivirus) { double(:antivirus) }
    let(:params) do
      ActionController::Parameters.new({
                                      benefit_area_file_step: {
                                        benefit_area_file: benefit_area_file
                                      }
                                    })
    end

    before do
      allow(PafsCore::AntivirusService).to receive(:new).and_return(antivirus)
      allow(antivirus).to receive(:scan).and_return(true)
    end

    context "with a valid shapefile" do
      let(:benefit_area_file) { fixture_file_upload("shapefile.zip") }

      it "saves the benefit area file" do
        expect(subject.update(params)).to be true
      end
    end

    context "with an invalid shapefile" do
      let(:benefit_area_file) { fixture_file_upload("shapefile_missing_dbf.zip") }

      it "does not save the benefit area file" do
        expect(subject.update(params)).to be false
      end
    end

    context "with a virus" do
      let(:benefit_area_file) { fixture_file_upload("virus.zip") }

      before do
        allow(antivirus).to receive(:scan).and_raise(PafsCore::VirusFoundError.new("shapefile.zip", "virus_name"))
      end

      it "does not save the benefit area file" do
        expect(subject.update(params)).to be false
      end
    end
  end
end
