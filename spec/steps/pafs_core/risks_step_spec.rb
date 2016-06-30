# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::RisksStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:risks_step) }

    it_behaves_like "a project step"

    it "validates that at least one risk source is selected" do
      subject.fluvial_flooding = false
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "Select the risks your project protects against"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:risks_step) }
    let(:params) {
      HashWithIndifferentAccess.new(
        { risks_step: {
            groundwater_flooding: "1",
            coastal_erosion: "1"
          }
        }
      )
    }
    let(:error_params) {
      HashWithIndifferentAccess.new(
        { risks_step: {
            fluvial_flooding: nil
          }
        }
      )
    }

    it "saves the state of valid params" do
      expect(subject.update(params)).to be true
      expect(subject.groundwater_flooding).to be true
      expect(subject.coastal_erosion).to be true
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :risks
      subject.update(params)
      expect(subject.step).to eq :main_risk
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :risks
      subject.update(error_params)
      expect(subject.step).to eq :risks
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:risks_step) }

    it "should return :map" do
      expect(subject.previous_step).to eq :map
    end
  end
end
