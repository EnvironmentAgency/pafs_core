# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::SurfaceAndGroundwaterStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:surface_and_groundwater_step) }

    it_behaves_like "a project step"

    it "validates that :improve_surface_or_groundwater has been set" do
      subject.improve_surface_or_groundwater = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_surface_or_groundwater]).
        to include "^Tell us if the project protects or improves surface water or groundwater"
    end
  end

  describe "#update" do
    subject { FactoryBot.create(:surface_and_groundwater_step) }
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :improve_surface_or_groundwater when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.improve_surface_or_groundwater).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.improve_surface_or_groundwater).to be false
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      surface_and_groundwater_step: { improve_surface_or_groundwater: value }
    )
  end
end
