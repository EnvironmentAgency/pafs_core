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
      end

      context "when :create_habitat set to false" do
        it "saves the value" do
          expect(subject.update(false_params)).to eq true
          expect(subject.create_habitat).to eq false
        end
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
      habitat_creation_step: { create_habitat: value }
    )
  end
end
