# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::RisksStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:risks_step) }

    it_behaves_like "a project step"

    it "validates that at least one risk source is selected" do
      subject.fluvial_flooding = false
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "Select the risks your project protects against"
    end
  end

  describe "#update" do
    subject { FactoryBot.create(:risks_step) }
    let(:params) do
      HashWithIndifferentAccess.new(
        { risks_step: {
          groundwater_flooding: "1",
          coastal_erosion: "1"
        } }
      )
    end
    let(:flood_params) do
      HashWithIndifferentAccess.new(
        { risks_step: {
          groundwater_flooding: "1"
        } }
      )
    end
    let(:coastal_params) do
      HashWithIndifferentAccess.new(
        { risks_step: {
          coastal_erosion: "1"
        } }
      )
    end
    let(:error_params) do
      HashWithIndifferentAccess.new(
        { risks_step: {
          fluvial_flooding: nil
        } }
      )
    end

    it "saves the state of valid params" do
      expect(subject.update(params)).to be true
      expect(subject.groundwater_flooding).to be true
      expect(subject.coastal_erosion).to be true
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    context "when only a single risk is selected" do
      it "auto sets the main risk" do
        subject.fluvial_flooding = nil
        expect { subject.update(flood_params) }
          .to change { subject.project.main_risk }.to "groundwater_flooding"
      end
    end
  end
end
