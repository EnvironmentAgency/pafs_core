# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ImproveSpaOrSacStep, type: :model do
  subject { FactoryBot.build(:improve_spa_or_sac_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :improve_spa_or_sac has been set" do
      subject.improve_spa_or_sac = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_spa_or_sac])
        .to include "^Tell us if the project protects or improves a Special "\
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

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      improve_spa_or_sac_step: { improve_spa_or_sac: value }
    )
  end
end
