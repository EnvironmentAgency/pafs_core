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

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to be false
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      fish_or_eel_amount_step: { fish_or_eel_amount: value }
    )
  end
end
