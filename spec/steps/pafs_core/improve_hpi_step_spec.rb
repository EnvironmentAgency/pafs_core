# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ImproveHpiStep, type: :model do
  subject { FactoryGirl.build(:improve_hpi_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :improve_hpi has been set" do
      subject.improve_hpi = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_hpi]).
        to include "^Tell us if the project protects or improves a Habitat of "\
                   "Principal Importance"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :improve_hpi when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.improve_hpi).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.improve_hpi).to be false
    end

    context "when :improve_hpi is true" do
      it "updates the next step to :improve_habitat_amount" do
        expect(subject.update(true_params)).to be true
        expect(subject.step).to eq :improve_habitat_amount
      end
    end

    context "when :improve_hpi is false" do
      it "updates the next step to :improve_river" do
        expect(subject.update(false_params)).to be true
        expect(subject.step).to eq :improve_river
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :improve_hpi
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
    context "when :improve_hpi nil" do
      it "returns false" do
        subject.improve_hpi = nil
        expect(subject.completed?).to be false
      end
    end

    context "when sub-tasks are not completed" do
      it "returns false" do
        expect(subject.completed?).to be false
      end
    end

    context "when :improve_hpi is true" do
      it "returns the result of sub-task #completed?" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::ImproveHabitatAmountStep).to receive(:new) { sub_step }
        subject.improve_hpi = true
        expect(subject.completed?).to be true
      end
    end

    context "when :improve_hpi is false" do
      it "returns the result of sub-task #completed?" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::ImproveRiverStep).to receive(:new) { sub_step }
        subject.improve_hpi = false
        expect(subject.completed?).to be true
      end
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      improve_hpi_step: { improve_hpi: value }
    )
  end
end
