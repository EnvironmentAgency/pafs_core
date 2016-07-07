# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FundingCalculatorSummaryStep, type: :model do
  before(:each) do
    @step = FactoryGirl.build(:funding_calculator_summary_step)
    @step.project.funding_calculator_file_name = "calc.xls"
    @step.project.funding_calculator_updated_at = 1.day.ago
  end

  subject { @step }

  describe "attributes" do
    it_behaves_like "a project step"
  end

  describe "#update" do
    it "points to the next step in the chain" do
      expect { subject.update({}) }.to change { subject.step }.to :summary
    end

    it "returns true" do
      expect(subject.update({})).to eq true
    end
  end

  describe "#previous_step" do
    it "should return :urgency" do
      expect(subject.previous_step).to eq :urgency
    end
  end

  describe "#is_current_step?" do
    context "as a sub-step of :funding_calculator" do
      it "returns true when passed :funding_calculator" do
        expect(subject.is_current_step?(:funding_calculator)).to eq true
      end
    end
  end
end
