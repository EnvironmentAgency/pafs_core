# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ImproveRiverStep, type: :model do
  subject { FactoryGirl.build(:improve_river_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :improve_river has been set" do
      subject.improve_river = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_river]).
        to include "^Tell us if the project protects or improves a length of river "\
                   "or priority river habitat"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    context "when params valid" do
      context "when :improve_river set to true" do
        it "saves the value" do
          expect(subject.update(true_params)).to eq true
          expect(subject.improve_river).to eq true
        end

        it "changes the next step to :improve_river_amount" do
          expect(subject.update(true_params)).to eq true
          expect(subject.step).to eq :improve_river_amount
        end
      end

      context "when :improve_river set to false" do
        it "saves the value" do
          expect(subject.update(false_params)).to eq true
          expect(subject.improve_river).to eq false
        end

        it "changes the next step to :habitat_improvement" do
          expect(subject.update(false_params)).to be true
          expect(subject.step).to eq :habitat_creation
        end
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :improve_river
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

  describe "#completed?" do
    context "when #invalid? true" do
      it "returns false" do
        subject.improve_river = nil
        expect(subject.completed?).to be false
      end
    end

    it "should return false when sub-tasks not completed" do
      expect(subject.completed?).to be false
    end

    context "when :improve_river is true" do
      it "returns result of PafsCore::ImproveRiverAmountStep#completed?" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::ImproveRiverAmountStep).to receive(:new) { sub_step }
        subject.improve_river = true
        expect(subject.completed?).to be true
      end
    end

    context "when :improve_river is false" do
      it "returns true" do
        subject.improve_river = false
        expect(subject.completed?).to be true
      end
    end
  end

  describe "#previous_step" do
    it "should return ::surface_and_groundwater_amount" do
      expect(subject.previous_step).to eq :surface_and_groundwater_amount
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      improve_river_step: { improve_river: value }
    )
  end
end
