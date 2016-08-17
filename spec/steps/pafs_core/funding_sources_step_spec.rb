# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FundingSourcesStep, type: :model do
  subject { FactoryGirl.build(:funding_sources_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that at least one funding source is selected" do
      subject.fcerm_gia = false
      subject.public_contributions = false
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "The project must have at least one funding source."
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:funding_sources_step) }
    let(:params) {
      HashWithIndifferentAccess.new({ funding_sources_step: { growth_funding: "1" }})
    }
    let(:error_params) {
      HashWithIndifferentAccess.new({ funding_sources_step: { fcerm_gia: nil }})
    }

    it "saves the state of valid params" do
      expect(subject.update(params)).to be true
      expect(subject.growth_funding).to be true
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
