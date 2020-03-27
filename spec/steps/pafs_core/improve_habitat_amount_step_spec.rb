# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ImproveHabitatAmountStep, type: :model do
  subject { FactoryBot.build(:improve_habitat_amount_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :improve_habitat_amount has been set" do
      subject.improve_habitat_amount = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_habitat_amount])
        .to include "^Enter a value to show how many hectares of habitat "\
                   "the project will protect or improve."
    end

    it "validates that :improve_habitat_amount is greater than zero" do
      subject.improve_habitat_amount = -234.4
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_habitat_amount])
        .to include "^Enter a value greater than zero to show how many hectares "\
                   "the project will protect or improve."
    end
  end

  describe "#update" do
    let(:valid_params) { make_params("205.25") }
    let(:error_params) { make_params(nil) }

    it "saves :improve_habitat_amount when valid" do
      expect(subject.update(valid_params)).to eq true
      expect(subject.improve_habitat_amount).to eq 205.25
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      improve_habitat_amount_step: { improve_habitat_amount: value }
    )
  end
end
