# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::StandardOfProtectionAfterStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:standard_of_protection_after_step) }

    it_behaves_like "a project step"

    it "validates that :flood_protection_before is present" do
      subject.flood_protection_after = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:flood_protection_after]).to include
      "^Select the option that shows the potential risk of flooding to the area after the project is complete."
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:standard_of_protection_after_step) }
    let(:params) do
      HashWithIndifferentAccess.new({
        standard_of_protection_after_step: {
          flood_protection_after: "3",
        }
      })
    end
    let(:error_params) do
      HashWithIndifferentAccess.new({
        standard_of_protection_after_step: {
          flood_protection_after: "2011"
        }
      })
    end

    it "saves the :project_type when valid" do
      expect(subject.flood_protection_after).not_to eq 3
      expect(subject.update(params)).to be true
      expect(subject.flood_protection_after).to eq 3
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end

  describe "#flood_risk_options" do
    subject { FactoryGirl.build(:standard_of_protection_after_step) }

    it "should return an array of options" do
      array_of_options = [:very_significant, :significant, :moderate, :low]

      expect(subject.flood_risk_options).to eq array_of_options
    end
  end
end
