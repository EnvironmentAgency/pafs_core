# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ImproveRiverStep, type: :model do
  subject { FactoryBot.build(:improve_river_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :improve_river has been set" do
      subject.improve_river = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_river])
        .to include "^Tell us if the project protects or improves a length of river "\
                   "or priority river habitat"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    context "when params valid" do
      context "when :improve_river set to true" do
        it "saves the value" do
          expect(subject.update(true_params)).to eq true
          expect(subject.improve_river).to eq true
        end
      end

      context "when :improve_river set to false" do
        it "saves the value" do
          expect(subject.update(false_params)).to eq true
          expect(subject.improve_river).to eq false
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
    ActionController::Parameters.new(
      improve_river_step: { improve_river: value }
    )
  end
end
