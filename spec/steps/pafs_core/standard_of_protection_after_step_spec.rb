# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::StandardOfProtectionAfterStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:standard_of_protection_after_step) }

    it_behaves_like "a project step"

    it "validates that :flood_protection_before is present" do
      subject.flood_protection_after = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:flood_protection_after]).to include
      "^Select the option that shows the potential risk of flooding to the area after the project is complete."
    end

    it "validates that :flood_protection_before is not greater than :flood_protection_after" do
      subject.project.flood_protection_before = 3
      subject.flood_protection_after = 1
      expect(subject.valid?).to eq false
      expect(subject.errors.messages[:flood_protection_after]).to include
      "^Once the project is complete the flood risk must be less than it is now"
    end
  end

  describe "#update" do
    subject { FactoryBot.create(:standard_of_protection_after_step) }
    let(:params) do
      HashWithIndifferentAccess.new({
                                      standard_of_protection_after_step: {
                                        flood_protection_after: "3"
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
    subject { FactoryBot.build(:standard_of_protection_after_step) }

    it "should return an array of options" do
      array_of_options = %i[very_significant significant moderate low]

      expect(subject.flood_risk_options).to eq array_of_options
    end
  end
end
