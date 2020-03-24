# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ConfidenceSecuredPartnershipFundingStep, type: :model do
  let(:project) { build(:project) }
  subject { FactoryBot.build(:confidence_secured_partnership_funding_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that at a confidence is selected" do
      subject.confidence_secured_partnership_funding = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:confidence_secured_partnership_funding]).to include "^Select the confidence level"
    end

    it "validates that the confidence is a valid value" do
      subject.confidence_secured_partnership_funding = "Invalid"
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:confidence_secured_partnership_funding]).to include "^Chosen level must be one of the valid values"
    end
  end

  describe "#update" do
    let(:params) do
      HashWithIndifferentAccess.new({
                                      confidence_secured_partnership_funding_step: {
                                        confidence_secured_partnership_funding: "high"
                                      }
                                    })
    end

    it "saves the state of valid params" do
      expect(subject.update(params)).to be true
      expect(subject.confidence_secured_partnership_funding).to eq "high"
    end
  end
end
