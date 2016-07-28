# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::StandardOfProtectionCoastalStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_step) }

    it_behaves_like "a project step"

    it "validates that :coastal_protection_before is present" do
      subject.coastal_protection_before = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:coastal_protection_before]).to include
      "^Select the option that shows the length of time before coastal \
      erosion affects the area likely to benefit from the project."
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:standard_of_protection_coastal_step) }
    let(:params) do
      HashWithIndifferentAccess.new({
        standard_of_protection_coastal_step: {
          coastal_protection_before: "1",
        }
      })
    end
    let(:error_params) do
      HashWithIndifferentAccess.new({
        standard_of_protection_coastal_step: {
          coastal_protection_before: "2011"
        }
      })
    end

    it "saves the :coastal_protection_before when valid" do
      expect(subject.coastal_protection_before).not_to eq 1
      expect(subject.update(params)).to be true
      expect(subject.coastal_protection_before).to eq 1
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :standard_of_protection_coastal
      subject.update(params)
      expect(subject.step).to eq :standard_of_protection_coastal_after
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :standard_of_protection_coastal
      subject.update(error_params)
      expect(subject.step).to eq :standard_of_protection_coastal
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_step) }

    context "when the project doesn't protect against flooding" do
      it "should return :coastal_protection_outcomes" do
        expect(subject.previous_step).to eq :coastal_erosion_protection_outcomes
      end
    end
    context "when the project does protect against flooding" do
      it "should return :standard_of_protection_after" do
        subject.project.fluvial_flooding = true && subject.project.save
        expect(subject.previous_step).to eq :standard_of_protection_after
      end
    end
  end

  describe "#is_current_step?" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_step) }

    context "when :standard_of_protection is given" do
      it "should return true" do
        expect(subject.is_current_step?(:standard_of_protection)).to eq true
      end
    end
  end

  describe "#disabled?" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_step) }
    it "should return true when the project doesn't protect households" do
      subject.project.project_type = "ENV_WITHOUT_HOUSEHOLDS"

      expect(subject.disabled?).to eq true
    end
  end

  describe "#standard_of_protection_options" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_step) }

    it "should return an array of options" do
      array_of_options = [:less_than_one_year, :one_to_four_years, :five_to_nine_years, :ten_years_or_more]

      expect(subject.standard_of_protection_options).to eq array_of_options
    end
  end
end
