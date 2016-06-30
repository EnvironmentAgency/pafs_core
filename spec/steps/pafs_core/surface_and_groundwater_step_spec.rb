# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::SurfaceAndGroundwaterStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:surface_and_groundwater_step) }

    it_behaves_like "a project step"

    it "validates that :improve_surface_or_groundwater has been set" do
      subject.improve_surface_or_groundwater = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_surface_or_groundwater]).
        to include "^Tell us if the project protects or improves surface water or groundwater"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:surface_and_groundwater_step) }
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :improve_surface_or_groundwater when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.improve_surface_or_groundwater).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.improve_surface_or_groundwater).to be false
    end

    context "when :improve_surface_or_groundwater is true" do
      it "updates the next step to :surface_and_groundwater_amount" do
        expect(subject.update(true_params)).to be true
        expect(subject.step).to eq :surface_and_groundwater_amount
      end
    end

    context "when :improve_surface_or_groundwater is false" do
      it "updates the next step to :improve_spa_or_sac" do
        expect(subject.update(false_params)).to be true
        expect(subject.step).to eq :improve_spa_or_sac
      end
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end

      it "does not change the next step" do
        expect(subject.update(error_params)).to be false
        expect(subject.step).to eq :surface_and_groundwater
      end
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:surface_and_groundwater_step) }

    it "should return :approach" do
      expect(subject.previous_step).to eq :approach
    end
  end

  describe "#completed?" do
    subject { FactoryGirl.build(:surface_and_groundwater_step) }

    it "should return false when :improve_surface_or_groundwater nil" do
      subject.improve_surface_or_groundwater = nil
      expect(subject.completed?).to be false
    end

    it "should return false when sub-tasks not completed" do
      expect(subject.completed?).to be false
    end

    it "should return true when sub-tasks completed" do
      subject.project.improve_surface_or_groundwater_amount = 10.5
      expect(subject.completed?).to be true
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      surface_and_groundwater_step: { improve_surface_or_groundwater: value }
    )
  end
end
