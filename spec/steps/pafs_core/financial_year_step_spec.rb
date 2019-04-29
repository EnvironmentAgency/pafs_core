# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FinancialYearStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:financial_year_step) }

    it_behaves_like "a project step"

    it "is validates :project_end_financial_year is not empty/falsey" do
      subject.project_end_financial_year = nil
      expect(subject.valid?).to be false
      expect(subject.errors[:project_end_financial_year]).to include(
        "^Tell us the financial year when the project will stop spending funds.")
    end

    # validates_numericality_of doesn't work with multiple qualifiers
    # in this case :only_integer, :less_than and :greater_than
    it "validates the numericality of :project_end_financial_year" do
      subject.project_end_financial_year = "abc"
      expect(subject.valid?).to be false
      expect(subject.errors[:project_end_financial_year]).to include(
        "^Tell us the financial year when the project will stop spending funds.")
    end

    it "validates that :project_end_financial_year is current financial year or later" do
      subject.project_end_financial_year = Time.current.uk_financial_year - 1
      current_financial_year = Time.current.uk_financial_year
      expect(subject.valid?).to be false
      expect(subject.errors[:project_end_financial_year]).to include(
        "^The financial year must be in the future")
    end

    it "validates that :project_end_financial_year is earlier than 2100" do
      subject.project_end_financial_year = 2101
      expect(subject.valid?).to be false
      expect(subject.errors[:project_end_financial_year]).to include(
        "must be 2100 or earlier")
    end
  end

  describe "#update" do
    subject { FactoryBot.create(:financial_year_step) }
    let(:params) { HashWithIndifferentAccess.new({ financial_year_step: { project_end_financial_year: "2020" }})}
    let(:error_params) { HashWithIndifferentAccess.new({ financial_year_step: { project_end_financial_year: "1983" }})}

    it "saves the :project_end_financial_year if valid" do
      expect(subject.project_end_financial_year).not_to eq 2020
      expect(subject.update(params)).to be true
      expect(subject.project_end_financial_year).to eq 2020
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end

  describe "#financial_year_options" do
    subject { FactoryBot.build(:financial_year_step) }

    it "should return the correct set of financial year options" do
      current_financial_year = Time.current.uk_financial_year
      expect(subject.financial_year_options).to eq current_financial_year..current_financial_year + 5
    end
  end
end
