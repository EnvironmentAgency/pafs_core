# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ConfidenceHomesByGatewayFourStep, type: :model do
  let(:project) { build(:project) }
  subject { FactoryBot.build(:confidence_homes_by_gateway_four_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that at a confidence is selected" do
      subject.confidence_homes_by_gateway_four = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:confidence_homes_by_gateway_four]).to include "^Select the confidence level"
    end

    it "validates that the confidence is a valid value" do
      subject.confidence_homes_by_gateway_four = "Invalid"
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:confidence_homes_by_gateway_four]).to include "^Chosen level must be one of the valid values"
    end
  end

  describe "#update" do
    let(:params) do
      HashWithIndifferentAccess.new({
                                      confidence_homes_by_gateway_four_step: {
                                        confidence_homes_by_gateway_four: "high"
                                      }
                                    })
    end

    it "saves the state of valid params" do
      expect(subject.update(params)).to be true
      expect(subject.confidence_homes_by_gateway_four).to eq "high"
    end
  end
end
