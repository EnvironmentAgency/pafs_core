# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::MainRiskStep, type: :model do
  before(:each) do
    @project = FactoryGirl.build(:main_risk_step)
    # required to be valid
    @project.project.update_attributes(groundwater_flooding: true)
    @project.project.save
  end
  subject { @project }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that at a main risk source is selected" do
      subject.main_risk = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:main_risk]).to include "must have a value"
    end

    it "validates that the main risk source is one of the selected risks" do
      subject.project.tidal_flooding = true
      subject.project.fluvial_flooding = false
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:main_risk]).to include "must be one of the selected risks"
    end
  end

  describe "#update" do
    let(:params) {
      HashWithIndifferentAccess.new(
        { main_risk_step: {
            main_risk: "groundwater_flooding"
          }
        }
      )
    }
    let(:error_params) {
      HashWithIndifferentAccess.new(
        { main_risk_step: {
            main_risk: nil
          }
        }
      )
    }

    it "saves the state of valid params" do
      expect(subject.update(params)).to be true
      expect(subject.main_risk).to eq "groundwater_flooding"
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :main_risk
      subject.update(params)
      expect(subject.step).to eq :households_benefiting
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :main_risk
      subject.update(error_params)
      expect(subject.step).to eq :main_risk
    end
  end

  describe "#previous_step" do
    it "should return :risks" do
      expect(subject.previous_step).to eq :risks
    end
  end

  describe "#risks" do
    it "returns a list of selected risks" do
      expect(subject.risks.count).to eq 1
    end
  end
end
