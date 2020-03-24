# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::StandardOfProtectionStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:standard_of_protection_step) }

    it_behaves_like "a project step"

    it "validates that :flood_protection_before is present" do
      subject.flood_protection_before = nil
      expect(subject.valid?).to eq false
      expect(subject.errors.messages[:flood_protection_before]).to include
      "^Select the option that shows the current risk of flooding to the area likely to benefit from the project."
    end

    it "validates that :flood_protection_before is not greater than :flood_protection_after" do
      subject.flood_protection_before = 3
      subject.project.flood_protection_after = 1
      expect(subject.valid?).to eq false
      expect(subject.errors.messages[:flood_protection_before]).to include
      "^Once the project is complete the flood risk must be less than it is now"
    end
  end

  describe "#update" do
    subject { FactoryBot.create(:standard_of_protection_step) }
    let(:params) do
      ActionController::Parameters.new({
                                      standard_of_protection_step: {
                                        flood_protection_before: "0"
                                      }
                                    })
    end
    let(:error_params) do
      ActionController::Parameters.new({
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

  describe "#flood_risk_options" do
    subject { FactoryBot.build(:standard_of_protection_step) }

    it "should return an array of options" do
      array_of_options = %i[very_significant significant moderate low]

      expect(subject.flood_risk_options).to eq array_of_options
    end
  end
end
