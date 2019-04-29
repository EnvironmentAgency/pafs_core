# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FundingCalculatorSummaryStep, type: :model do
  before(:each) do
    @step = FactoryBot.build(:funding_calculator_summary_step)
    @step.project.funding_calculator_file_name = "calc.xls"
    @step.project.funding_calculator_updated_at = 1.day.ago
  end

  subject { @step }

  describe "attributes" do
    it_behaves_like "a project step"
  end

  describe "#update" do
    it "returns true" do
      expect(subject.update({})).to eq true
    end
  end
end
