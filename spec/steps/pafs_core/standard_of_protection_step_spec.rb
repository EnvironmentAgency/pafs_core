# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::StandardOfProtectionStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:standard_of_protection_step) }

    it_behaves_like "a project step"

    it "validates that :flood_protection_before is present" do
      subject.flood_protection_before = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:flood_protection_before]).to include
      "^Select the option that shows the current risk of flooding to the area likely to benefit from the project."
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:standard_of_protection_step) }
    let(:params) do
      HashWithIndifferentAccess.new({
        standard_of_protection_step: {
          flood_protection_before: "0",
        }
      })
    end
    let(:error_params) do
      HashWithIndifferentAccess.new({
        standard_of_protection_step: {
          flood_protection_before: "2011"
        }
      })
    end

    it "saves the :flood_protection_before when valid" do
      expect(subject.flood_protection_before).not_to eq 0
      expect(subject.update(params)).to be true
      expect(subject.flood_protection_before).to eq 0
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end

  describe "#standard_of_protection_options" do
    subject { FactoryGirl.build(:standard_of_protection_step) }

    it "should return an array of options" do
      array_of_options = [:very_significant, :significant, :moderate, :low]

      expect(subject.standard_of_protection_options).to eq array_of_options
    end
  end
end
