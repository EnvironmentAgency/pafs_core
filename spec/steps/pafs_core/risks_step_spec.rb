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
    let(:flood_params) {
      HashWithIndifferentAccess.new(
        { risks_step: {
            groundwater_flooding: "1",
          }
        }
      )
    }
    let(:coastal_params) {
      HashWithIndifferentAccess.new(
        { risks_step: {
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

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :risks
      subject.update(error_params)
      expect(subject.step).to eq :risks
    end

    context "when valid? true" do
      before(:each) { subject.fluvial_flooding = nil }

      context "when multiple risks are selected" do
        it "updates the next step to :main_risk" do
          expect(subject.step).to eq :risks
          subject.update(params)
          expect(subject.step).to eq :main_risk
        end
      end
      context "when a single flood risk is selected" do
        it "updates the next step to :flood_protection_outcomes" do
          expect(subject.step).to eq :risks
          subject.update(flood_params)
          expect(subject.step).to eq :flood_protection_outcomes
        end
      end
      context "when only coastal erosion risk is selected" do
        it "updates the next step to :coastal_erosion_protection_outcomes" do
          expect(subject.step).to eq :risks
          subject.update(coastal_params)
          expect(subject.step).to eq :coastal_erosion_protection_outcomes
        end
      end
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:risks_step) }

    # TODO: this needs to be changed to :map once the map is integrated
    it "should return :earliest_start" do
      expect(subject.previous_step).to eq :earliest_start
    end
  end

  describe "#disabled?" do
    subject { FactoryGirl.build(:risks_step) }

    it "should return true when the project doesn't protect households" do
      subject.project.project_type = "ENV_WITHOUT_HOUSEHOLDS"

      expect(subject.disabled?).to eq true
    end
  end
end
