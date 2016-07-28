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

    context "when project protects against coastal erosion" do
      it "updates the next step if valid" do
        subject.project.coastal_erosion = true && subject.project.save
        expect(subject.step).to eq :standard_of_protection_after
        subject.update(params)
        expect(subject.step).to eq :standard_of_protection_coastal
      end
    end

    context "when project doesn't protect against coastal erosion" do
      it "updates the next step if valid" do
        expect(subject.step).to eq :standard_of_protection_after
        subject.update(params)
        expect(subject.step).to eq :approach
      end
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :standard_of_protection_after
      subject.update(error_params)
      expect(subject.step).to eq :standard_of_protection_after
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:standard_of_protection_after_step) }

    it "should return :standard_of_protection" do
      expect(subject.previous_step).to eq :standard_of_protection
    end
  end

  describe "#completed?" do
    subject { FactoryGirl.build(:standard_of_protection_after_step) }

    context "when not valid" do
      it "returns false" do
        subject.flood_protection_after = nil
        expect(subject.completed?).to eq false
      end
    end

    context "when step is valid" do
      context "when the coastal sub-step is invalid" do
        it "returns false" do
          expect(subject.completed?).to eq false
        end
      end

      context "when the coastal sub-step is valid" do
        it "returns true" do
          subject.project.update_attributes FactoryGirl.attributes_for(:standard_of_protection_coastal_step)
          expect(subject.completed?).to be true
        end
      end
    end
  end

  describe "#disabled?" do
    subject { FactoryGirl.build(:standard_of_protection_after_step) }

    it "should return true when the project doesn't protect households" do
      subject.project.project_type = "ENV_WITHOUT_HOUSEHOLDS"

      expect(subject.disabled?).to eq true
    end
  end

  describe "#standard_of_protection_options" do
    subject { FactoryGirl.build(:standard_of_protection_after_step) }

    it "should return an array of options" do
      array_of_options = [:very_significant, :significant, :moderate, :low]

      expect(subject.standard_of_protection_options).to eq array_of_options
    end
  end

  describe "#is_current_step?" do
    subject { FactoryGirl.build(:standard_of_protection_after_step) }

    context "when :standard_of_protection is given" do
      it "should return true" do
        expect(subject.is_current_step?(:standard_of_protection)).to eq true
      end
    end
  end
end
