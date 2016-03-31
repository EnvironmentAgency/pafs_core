# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
require_relative "./shared_step_spec"

RSpec.describe PafsCore::FinancialYearStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:financial_year_step) }

    it_behaves_like "a project step"

    it { is_expected.to validate_presence_of :project_end_financial_year }

    # validates_numericality_of doesn't seem to work with multiple qualifiers
    # in this case :only_integer, :less_than and :greater_than
    it "validates the numericality of :project_end_financial_year" do
      subject.project_end_financial_year = "abc"
      expect(subject.valid?).to be false
      expect(subject.project_end_financial_year).to eq(0)
      expect(subject.errors[:project_end_financial_year]).not_to be_nil
    end

    it "validates that :project_end_financial_year is later than 2015" do
      subject.project_end_financial_year = 2015
      expect(subject.valid?).to be false
      expect(subject.errors[:project_end_financial_year]).to include "must be later than 2015"
    end

    it "validates that :project_end_financial_year is earlier than 2100" do
      subject.project_end_financial_year = 2100
      expect(subject.valid?).to be false
      expect(subject.errors[:project_end_financial_year]).to include "must be earlier than 2100"
    end
  end
end
