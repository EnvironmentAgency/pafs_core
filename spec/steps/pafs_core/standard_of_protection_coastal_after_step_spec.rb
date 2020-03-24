# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::StandardOfProtectionCoastalAfterStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:standard_of_protection_coastal_after_step) }

    it_behaves_like "a project step"

    it "validates that :coastal_protection_after is present" do
      subject.coastal_protection_after = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:coastal_protection_after]).to include
      "^Select the option that shows the length of time before coastal \
      erosion affects the area likely to benefit from the project."
    end

    it "validates that :coastal_protection_before is not greater than :coastal_protection_after" do
      subject.coastal_protection_before = 3
      subject.coastal_protection_after = 0
      expect(subject.valid?).to eq false
      expect(subject.errors.messages[:coastal_protection_after]).to include
      "^Once the project is complete the length of time before"\
        " coastal erosion affects the area must be greater than it"\
        " is now"
    end
  end

  describe "#update" do
    subject { FactoryBot.create(:standard_of_protection_coastal_after_step) }
    let(:params) do
      HashWithIndifferentAccess.new({
                                      standard_of_protection_coastal_after_step: {
                                        coastal_protection_after: "0"
                                      }
                                    })
    end
    let(:error_params) do
      HashWithIndifferentAccess.new({
                                      standard_of_protection_coastal_after_step: {
                                        coastal_protection_after: "2011"
                                      }
                                    })
    end

    it "saves the :project_type when valid" do
      expect(subject.coastal_protection_after).not_to eq 0
      expect(subject.update(params)).to be true
      expect(subject.coastal_protection_after).to eq 0
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end

  describe "#coastal_erosion_after_options" do
    subject { FactoryBot.build(:standard_of_protection_coastal_after_step) }

    it "should return an array of options" do
      array_of_options = %i[
        less_than_ten_years
        ten_to_nineteen_years
        twenty_to_fortynine_years
        fifty_years_or_more
      ]

      expect(subject.coastal_erosion_after_options).to eq array_of_options
    end
  end
end
