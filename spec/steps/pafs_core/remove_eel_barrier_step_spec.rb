# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::RemoveEelBarrierStep, type: :model do
  subject { FactoryGirl.build(:remove_eel_barrier_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :remove_eel_barrier has been set" do
      subject.remove_eel_barrier = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:remove_eel_barrier]).
        to include "^Tell us if the project removes a barrier to migration for eels"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    context "when params valid" do
      it "saves the value" do
        expect(subject.update(false_params)).to eq true
        expect(subject.remove_eel_barrier).to eq false
      end

      context "when remove_eel_barrier? is true" do
        it "changes the next step to :fish_or_eel_amount" do
          expect(subject.update(true_params)).to eq true
          expect(subject.step).to eq :fish_or_eel_amount
        end
      end

      context "when remove_eel_barrier? is false" do
        context "when remove_fish_barrier? is true" do
          it "changes the next step to :fish_or_eel_amount" do
            subject.project.update_attributes(remove_fish_barrier: true)
            expect(subject.update(false_params)).to eq true
            expect(subject.step).to eq :fish_or_eel_amount
          end
        end

        context "when remove_fish_barrier? is false" do
          it "changes the next step to :urgency" do
            subject.project.update_attributes(remove_fish_barrier: false)
            expect(subject.update(false_params)).to eq true
            expect(subject.step).to eq :urgency
          end
        end
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :remove_eel_barrier
      end
    end
  end

  describe "#is_current_step?" do
    context "when given :remove_fish_barrier" do
      it "returns true" do
        expect(subject.is_current_step?(:remove_fish_barrier)).to eq true
      end
    end
    context "when not given :remove_fish_barrier" do
      it "returns false" do
        expect(subject.is_current_step?(:broccoli)).to eq false
      end
    end
  end

  describe "#completed?" do
    context "when #invalid?" do
      it "returns false" do
        subject.remove_eel_barrier = nil
        expect(subject.valid?).to eq false
        expect(subject.completed?).to eq false
      end
    end

    it "should return false when sub-tasks not completed" do
      expect(subject.completed?).to eq false
    end

    context "when #valid?" do
      it "returns result of PafsCore::FishOrEelAmountStep#completed?" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::FishOrEelAmountStep).to receive(:new) { sub_step }
        subject.remove_eel_barrier = true
        expect(subject.valid?).to eq true
        expect(subject.completed?).to eq true
      end
    end
  end

  describe "#previous_step" do
    it "should return :habitat_creation" do
      expect(subject.previous_step).to eq :habitat_creation
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      remove_eel_barrier_step: { remove_eel_barrier: value }
    )
  end
end
