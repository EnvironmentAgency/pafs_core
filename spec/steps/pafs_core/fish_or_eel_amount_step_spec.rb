# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FishOrEelAmountStep, type: :model do
  subject { FactoryGirl.build(:fish_or_eel_amount_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :fish_or_eel_amount has been set" do
      subject.fish_or_eel_amount = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:fish_or_eel_amount]).
        to include "^Enter a value to show how many kilometres of river "\
                   "the project is likely to open for fish or eel passage."
    end

    it "validates that :fish_or_eel_amount is greater than zero" do
      subject.fish_or_eel_amount = -234.4
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:fish_or_eel_amount]).
        to include "^Enter a value greater than zero to show how many kilometres "\
                   "of river the project is likely to open for fish or eel passage."
    end
  end

  describe "#update" do
    let(:valid_params) { make_params("205.25") }
    let(:error_params) { make_params(nil) }

    it "saves :fish_or_eel_amount when valid" do
      expect(subject.update(valid_params)).to eq true
      expect(subject.fish_or_eel_amount).to eq 205.25
    end

    it "updates the next step to :urgency" do
      expect(subject.update(valid_params)).to be true
      expect(subject.step).to eq :urgency
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :fish_or_eel_amount
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

  describe "#previous_step" do
    it "should return :habitat_creation" do
      expect(subject.previous_step).to eq :habitat_creation
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      fish_or_eel_amount_step: { fish_or_eel_amount: value }
    )
  end
end
