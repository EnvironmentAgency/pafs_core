# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ImproveHpiStep, type: :model do
  subject { FactoryGirl.build(:improve_hpi_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :improve_hpi has been set" do
      subject.improve_hpi = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:improve_hpi]).
        to include "^Tell us if the project protects or improves a Habitat of "\
                   "Principal Importance"
    end
  end

  describe "#update" do
    let(:true_params) { make_params("true") }
    let(:false_params) { make_params("false") }
    let(:error_params) { make_params(nil) }

    it "saves :improve_hpi when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.improve_hpi).to be true
      expect(subject.update(false_params)).to be true
      expect(subject.improve_hpi).to be false
    end

    context "when validation fails" do
      it "returns false" do
        expect(subject.update(error_params)).to be false
      end
    end
  end

  def make_params(value)
    HashWithIndifferentAccess.new(
      improve_hpi_step: { improve_hpi: value }
    )
  end
end
