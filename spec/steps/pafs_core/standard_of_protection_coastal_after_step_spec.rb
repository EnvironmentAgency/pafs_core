# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::StandardOfProtectionCoastalAfterStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_after_step) }

    it_behaves_like "a project step"

    it "validates that :coastal_protection_after is present" do
      subject.coastal_protection_after = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:coastal_protection_after]).to include
      "^Select the option that shows the length of time before coastal \
      erosion affects the area likely to benefit from the project."
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:standard_of_protection_coastal_after_step) }
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

    it "updates the next step if valid" do
      expect(subject.step).to eq :standard_of_protection_coastal_after
      subject.update(params)
      expect(subject.step).to eq :approach
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :standard_of_protection_coastal_after
      subject.update(error_params)
      expect(subject.step).to eq :standard_of_protection_coastal_after
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_after_step) }

    it "should return :standard_of_protection_coastal" do
      expect(subject.previous_step).to eq :standard_of_protection_coastal
    end
  end

  describe "#is_current_step?" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_after_step) }

    context "when :standard_of_protection is given" do
      it "should return true" do
        expect(subject.is_current_step?(:standard_of_protection)).to eq true
      end
    end
  end

  describe "#disabled?" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_after_step) }
    it "should return true when the project doesn't protect households" do
      subject.project.project_type = "ENV_WITHOUT_HOUSEHOLDS"

      expect(subject.disabled?).to eq true
    end
  end

  describe "#standard_of_protection_options" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_after_step) }

    it "should return an array of options" do
      array_of_options = [
                          :less_than_ten_years,
                          :ten_to_nineteen_years,
                          :twenty_to_fortynine_years,
                          :fifty_years_or_more
                         ]

      expect(subject.standard_of_protection_options).to eq array_of_options
    end
  end
end
