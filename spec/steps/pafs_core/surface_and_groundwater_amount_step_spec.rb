# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::SurfaceAndGroundwaterAmountStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:surface_and_groundwater_amount_step) }

    it_behaves_like "a project step"

    it "validates that :improve_surface_or_groundwater_amount is present" do
      subject.improve_surface_or_groundwater_amount = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_surface_or_groundwater_amount]).
        to include "^Enter a value to show how many kilometers of surface water "\
                   "or groundwater the project will protect or improve."
    end

    it "validates that :improve_surface_or_groundwater_amount is greater than 0" do
      subject.improve_surface_or_groundwater_amount = 0
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_surface_or_groundwater_amount]).
        to include "^Enter a value greater than zero to show how many kilometers "\
                   "the project will protect or improve."
    end
  end

  describe "#is_current_step?" do
    subject { FactoryGirl.build(:surface_and_groundwater_amount_step) }
    context "when passed :surface_and_groundwater" do
      it "returns true" do
        expect(subject.is_current_step?(:surface_and_groundwater)).to eq true
      end
    end
  end

  describe "#update" do
    subject { FactoryGirl.build(:surface_and_groundwater_amount_step) }
    let(:valid_params) { make_params(200) }
    let(:error_params) { make_params(-200) }

    it "saves the :improve_surface_or_groundwater_amount when valid" do
      expect(subject.update(valid_params)).to be true
      expect(subject.improve_surface_or_groundwater_amount).to eq 200
    end

    it "updates the next step to :improve_river after a successful update" do
      expect(subject.update(valid_params)).to be true
      expect(subject.step).to eq :improve_river
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :surface_and_groundwater_amount
      end
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:surface_and_groundwater_amount_step) }

    it "should return :surface_and_groundwater" do
      expect(subject.previous_step).to eq :surface_and_groundwater
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      surface_and_groundwater_amount_step: {
        improve_surface_or_groundwater_amount: value
      }
    )
  end
end
