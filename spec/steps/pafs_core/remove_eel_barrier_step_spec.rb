# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::RemoveEelBarrierStep, type: :model do
  subject { FactoryBot.build(:remove_eel_barrier_step) }

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
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      remove_eel_barrier_step: { remove_eel_barrier: value }
    )
  end
end
