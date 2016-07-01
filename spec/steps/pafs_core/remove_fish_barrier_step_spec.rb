# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::RemoveFishBarrierStep, type: :model do
  subject { FactoryGirl.build(:remove_fish_barrier_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :remove_fish_barrier has been set" do
      subject.remove_fish_barrier = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:remove_fish_barrier]).
        to include "^Tell us if the project removes a barrier to migration for fish"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    context "when params valid" do
      it "saves the value" do
        expect(subject.update(false_params)).to eq true
        expect(subject.remove_fish_barrier).to eq false
      end

      it "changes the next step to :habitat_creation_amount" do
        expect(subject.update(true_params)).to eq true
        expect(subject.step).to eq :remove_eel_barrier
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :remove_fish_barrier
      end
    end
  end

  describe "#completed?" do
    context "when #invalid?" do
      it "returns false" do
        subject.remove_fish_barrier = nil
        expect(subject.valid?).to eq false
        expect(subject.completed?).to eq false
      end
    end

    it "should return false when sub-tasks not completed" do
      expect(subject.completed?).to eq false
    end

    context "when #valid?" do
      it "returns result of PafsCore::RemoveEelBarrierStep#completed?" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::RemoveEelBarrierStep).to receive(:new) { sub_step }
        subject.remove_fish_barrier = true
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
      remove_fish_barrier_step: { remove_fish_barrier: value }
    )
  end
end
