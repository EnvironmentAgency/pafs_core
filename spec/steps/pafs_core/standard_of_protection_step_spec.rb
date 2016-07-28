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

    it "updates the next step if valid" do
      expect(subject.step).to eq :standard_of_protection
      subject.update(params)
      expect(subject.step).to eq :standard_of_protection_after
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :standard_of_protection
      subject.update(error_params)
      expect(subject.step).to eq :standard_of_protection
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:standard_of_protection_step) }

    context "when the project protects against coastal erosion" do
      it "should return :coastal_erosion_protection_outcomes" do
        subject.project.coastal_erosion = true && subject.project.save
        expect(subject.previous_step).to eq :coastal_erosion_protection_outcomes
      end
    end

    context "when the project doesn't protect against coastal erosion" do
      it "should return :flood_protection_outcomes" do
        expect(subject.previous_step).to eq :flood_protection_outcomes
      end
    end
  end

  describe "#completed?" do
    subject { FactoryGirl.build(:standard_of_protection_step) }

    context "when not valid" do
      it "returns false" do
        subject.flood_protection_before = nil
        expect(subject.completed?).to eq false
      end
    end

    context "when step is valid" do
      context "when the coastal sub-step is invalid" do
        it "returns false" do
          subject.project.coastal_erosion = true && subject.project.save
          expect(subject.completed?).to eq false
        end
      end

      context "when the coastal sub-step is valid" do
        it "returns true" do
          expect(subject.completed?).to be true
        end
      end
    end
  end

  describe "#disabled?" do
    subject { FactoryGirl.build(:standard_of_protection_step) }

    it "should return true when the project doesn't protect households" do
      subject.project.project_type = "ENV_WITHOUT_HOUSEHOLDS"

      expect(subject.disabled?).to eq true
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
