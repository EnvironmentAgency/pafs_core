# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::HabitatCreationStep, type: :model do
  subject { FactoryGirl.build(:habitat_creation_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :create_habitat has been set" do
      subject.create_habitat = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:create_habitat]).
        to include "^Tell us if the project creates habitat"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    context "when params valid" do
      context "when :create_habitat set to true" do
        it "saves the value" do
          expect(subject.update(true_params)).to eq true
          expect(subject.create_habitat).to eq true
        end

        it "changes the next step to :habitat_creation_amount" do
          expect(subject.update(true_params)).to eq true
          expect(subject.step).to eq :habitat_creation_amount
        end
      end

      context "when :create_habitat set to false" do
        it "saves the value" do
          expect(subject.update(false_params)).to eq true
          expect(subject.create_habitat).to eq false
        end

        it "changes the next step to :remove_fish_barrier" do
          expect(subject.update(false_params)).to be true
          expect(subject.step).to eq :remove_fish_barrier
        end
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :habitat_creation
      end
    end
  end

  describe "#completed?" do
    context "when #invalid?" do
      it "returns false" do
        subject.create_habitat = nil
        expect(subject.completed?).to be false
      end
    end

    it "should return false when sub-tasks not completed" do
      expect(subject.completed?).to be false
    end

    context "when :create_habitat is true" do
      it "returns result of PafsCore::HabitatCreationAmountStep#completed?" do
        sub_step = double("sub_step")
        expect(sub_step).to receive(:completed?) { true }
        expect(PafsCore::HabitatCreationAmountStep).to receive(:new) { sub_step }
        subject.create_habitat = true
        expect(subject.completed?).to be true
      end
    end

    context "when :create_habitat is false" do
      it "returns true" do
        subject.create_habitat = false
        expect(subject.completed?).to be true
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
      habitat_creation_step: { create_habitat: value }
    )
  end
end
