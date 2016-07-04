# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::StandardOfProtectionCoastalStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:standard_of_protection_coastal_step) }

    it_behaves_like "a project step"

    it "validates that :coastal_protection_before is present" do
      subject.coastal_protection_before = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:coastal_protection_before]).to include "can't be blank"
    end

    it "validates that :coastal_protection_before is in the range 0-100" do
      [-1, 101].each do |num|
        subject.coastal_protection_before = num
        expect(subject.valid?).to be false
        expect(subject.errors.messages[:coastal_protection_before]).to include "must be a value in the range 0 to 100"
      end
    end

    it "validates that :coastal_protection_after is present" do
      subject.coastal_protection_after = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:coastal_protection_after]).to include "can't be blank"
    end

    it "validates that :coastal_protection_after is in the range 0-100" do
      [-1, 101].each do |num|
        subject.coastal_protection_after = num
        expect(subject.valid?).to be false
        expect(subject.errors.messages[:coastal_protection_after]).to include "must be a value in the range 0 to 100"
      end
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:standard_of_protection_coastal_step) }
    let(:params) do
      HashWithIndifferentAccess.new({
        standard_of_protection_coastal_step: {
          coastal_protection_before: "35",
          coastal_protection_after: "11"
        }
      })
    end
    let(:error_params) do
      HashWithIndifferentAccess.new({
        standard_of_protection_coastal_step: {
          coastal_protection_after: "2011"
        }
      })
    end

    it "saves the :project_type when valid" do
      expect(subject.coastal_protection_before).not_to eq 35
      expect(subject.update(params)).to be true
      expect(subject.coastal_protection_before).to eq 35
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :standard_of_protection_coastal
      subject.update(params)
      expect(subject.step).to eq :approach
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

    it "should return :standard_of_protection" do
      expect(subject.previous_step).to eq :standard_of_protection
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
end
