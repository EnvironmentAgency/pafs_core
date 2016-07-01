# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::HabitatCreationAmountStep, type: :model do
  subject { FactoryGirl.build(:habitat_creation_amount_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :create_habitat_amount has been set" do
      subject.create_habitat_amount = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:create_habitat_amount]).
        to include "^Enter a value to show how many hectares of habitat "\
                   "the project is likely to create."
    end

    it "validates that :create_habitat_amount is greater than zero" do
      subject.create_habitat_amount = -234.4
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:create_habitat_amount]).
        to include "^Enter a value greater than zero to show how many hectares "\
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

    it "updates the next step to :remove_fish_barrier" do
      expect(subject.update(valid_params)).to be true
      expect(subject.step).to eq :remove_fish_barrier
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :habitat_creation_amount
      end
    end
  end

  describe "#is_current_step?" do
    context "when given :habitat_creation" do
      it "returns true" do
        expect(subject.is_current_step?(:habitat_creation)).to eq true
      end
    end
    context "when not given :habitat_creation" do
      it "returns false" do
        expect(subject.is_current_step?(:broccoli)).to eq false
      end
    end
  end

  describe "#previous_step" do
    it "should return :improve_spa_or_sac" do
      expect(subject.previous_step).to eq :improve_spa_or_sac
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      habitat_creation_amount_step: { create_habitat_amount: value }
    )
  end
end
