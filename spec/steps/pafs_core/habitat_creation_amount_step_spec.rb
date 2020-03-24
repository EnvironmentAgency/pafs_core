# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::HabitatCreationAmountStep, type: :model do
  subject { FactoryBot.build(:habitat_creation_amount_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :create_habitat_amount has been set" do
      subject.create_habitat_amount = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:create_habitat_amount])
        .to include "^Enter a value to show how many hectares of habitat "\
                   "the project is likely to create."
    end

    it "validates that :create_habitat_amount is greater than zero" do
      subject.create_habitat_amount = -234.4
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:create_habitat_amount])
        .to include "^Enter a value greater than zero to show how many hectares "\
                   "the project is likely to create."
    end
  end

  describe "#update" do
    let(:valid_params) { make_params("205.25") }
    let(:error_params) { make_params(nil) }

    it "saves :create_habitat_amount when valid" do
      expect(subject.update(valid_params)).to eq true
      expect(subject.create_habitat_amount).to eq 205.25
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end
    end
  end

  def make_params(value)
    ActionController::Parameters.new(
      habitat_creation_amount_step: { create_habitat_amount: value }
    )
  end
end
