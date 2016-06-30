# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ImproveHabitatAmountStep, type: :model do
  subject { FactoryGirl.build(:improve_habitat_amount_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :improve_habitat_amount has been set" do
      subject.improve_habitat_amount = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_habitat_amount]).
        to include "^Enter a value to show how many hectares of habitat "\
                   "the project will protect or improve."
    end

    it "validates that :improve_habitat_amount is greater than zero" do
      subject.improve_habitat_amount = -234.4
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_habitat_amount]).
        to include "^Enter a value greater than zero to show how many hectares "\
                   "the project will protect or improve."
    end
  end

  describe "#update" do
    let(:valid_params) { make_params("205.25") }
    let(:error_params) { make_params(nil) }

    it "saves :improve_habitat_amount when valid" do
      expect(subject.update(valid_params)).to eq true
      expect(subject.improve_habitat_amount).to eq 205.25
    end

    it "updates the next step to :improve_river" do
      expect(subject.update(valid_params)).to be true
      expect(subject.step).to eq :improve_river
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :improve_habitat_amount
      end
    end
  end

  describe "#is_current_step?" do
    context "when given :improve_spa_or_sac" do
      it "returns true" do
        expect(subject.is_current_step?(:improve_spa_or_sac)).to eq true
      end
    end
    context "when not given :improve_spa_or_sac" do
      it "returns false" do
        expect(subject.is_current_step?(:broccoli)).to eq false
      end
    end
  end

  describe "#previous_step" do
    it "should return :surface_and_groundwater" do
      expect(subject.previous_step).to eq :surface_and_groundwater
    end
  end

  describe "#completed?" do
    context "when :improve_habitat_amount invalid" do
      it "returns false" do
        subject.improve_habitat_amount = nil
        expect(subject.completed?).to be false
      end
    end

    context "when sub-tasks are not completed" do
      it "returns false" do
        expect(subject.completed?).to be false
      end
    end

    context "when :improve_habitat_amount is valid" do
      it "returns the result of sub-task #completed?" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::ImproveRiverStep).to receive(:new) { sub_step }
        subject.improve_habitat_amount = 1.5
        expect(subject.completed?).to be true
      end
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      improve_habitat_amount_step: { improve_habitat_amount: value }
    )
  end
end
