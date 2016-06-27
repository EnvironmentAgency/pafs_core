# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ImproveRiverStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:improve_river_step) }

    it_behaves_like "a project step"

    it "validates that :improve_river has been set" do
      subject.improve_river = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_river]).
        to include "^Tell us if the project protects or improves a length of river "\
                    "or priority river habitat"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:improve_river_step) }
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    context "when params valid" do
      it "saves :improve_river" do
        expect(subject.update(true_params)).to be true
        expect(subject.improve_river).to be true
        expect(subject.update(false_params)).to be true
        expect(subject.improve_river).to be false
      end

      it "updates the next step to :habitat_improvement" do
        expect(subject.update(true_params)).to be true
        expect(subject.step).to eq :habitat_improvement
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :improve_river
      end
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:improve_river_step) }

    it "should return ::surface_and_groundwater_amount" do
      expect(subject.previous_step).to eq :surface_and_groundwater_amount
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      improve_river_step: { improve_river: value }
    )
  end
end
