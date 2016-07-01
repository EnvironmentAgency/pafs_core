# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ImproveSpaOrSacStep, type: :model do
  subject { FactoryGirl.build(:improve_spa_or_sac_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :improve_spa_or_sac has been set" do
      subject.improve_spa_or_sac = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_spa_or_sac]).
        to include "^Tell us if the project protects or improves a Special "\
                   "Protected Area or Special Area of Conservation"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :improve_spa_or_sac when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.improve_spa_or_sac).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.improve_spa_or_sac).to be false
    end

    context "when :improve_spa_or_sac is true" do
      it "updates the next step to :improve_habitat_amount" do
        expect(subject.update(true_params)).to be true
        expect(subject.step).to eq :improve_habitat_amount
      end
    end

    context "when :improve_spa_or_sac is false" do
      it "updates the next step to :improve_sssi" do
        expect(subject.update(false_params)).to be true
        expect(subject.step).to eq :improve_sssi
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :improve_spa_or_sac
      end
    end
  end

  describe "#previous_step" do
    it "should return :surface_and_groundwater" do
      expect(subject.previous_step).to eq :surface_and_groundwater
    end
  end

  describe "#completed?" do
    it "should return false when :improve_spa_or_sac nil" do
      subject.improve_spa_or_sac = nil
      expect(subject.completed?).to be false
    end

    it "should return false when sub-tasks not completed" do
      expect(subject.completed?).to be false
    end

    context "when :improve_spa_or_sac is true" do
      it "should return true when PafsCore::ImproveHabitatAmountStep complete" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::ImproveHabitatAmountStep).to receive(:new) { sub_step }
        subject.improve_spa_or_sac = true
        expect(subject.completed?).to be true
      end
    end

    context "when :improve_spa_or_sac is false" do
      it "should return true when PafsCore::ImproveSssiStep complete" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::ImproveSssiStep).to receive(:new) { sub_step }
        subject.improve_spa_or_sac = false
        expect(subject.completed?).to be true
      end
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      improve_spa_or_sac_step: { improve_spa_or_sac: value }
    )
  end
end
