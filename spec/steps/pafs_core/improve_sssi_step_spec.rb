# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ImproveSssiStep, type: :model do
  subject { FactoryGirl.build(:improve_sssi_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :improve_sssi has been set" do
      subject.improve_sssi = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_sssi]).
        to include "^Tell us if the project protects or improves a Site of Special "\
                   "Scientific Interest"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :improve_sssi when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.improve_sssi).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.improve_sssi).to be false
    end

    context "when :improve_sssi is true" do
      it "updates the next step to :improve_habitat_amount" do
        expect(subject.update(true_params)).to be true
        expect(subject.step).to eq :improve_habitat_amount
      end
    end

    context "when :improve_sssi is false" do
      it "updates the next step to :improve_hpi" do
        expect(subject.update(false_params)).to be true
        expect(subject.step).to eq :improve_hpi
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :improve_sssi
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
    it "should return false when :improve_sssi nil" do
      subject.improve_sssi = nil
      expect(subject.completed?).to be false
    end

    it "should return false when sub-tasks not completed" do
      expect(subject.completed?).to be false
    end

    context "when :improve_sssi is true" do
      it "should return true when PafsCore::ImproveHabitatAmountStep complete" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::ImproveHabitatAmountStep).to receive(:new) { sub_step }
        subject.improve_sssi = true
        expect(subject.completed?).to be true
      end
    end

    context "when :improve_sssi is false" do
      it "should return true when PafsCore::ImproveHpiStep complete" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::ImproveHpiStep).to receive(:new) { sub_step }
        subject.improve_sssi = false
        expect(subject.completed?).to be true
      end
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      improve_sssi_step: { improve_sssi: value }
    )
  end
end
