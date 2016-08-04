# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::FinancialYearStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:financial_year_step) }

    it_behaves_like "a project step"

    it "is validates :project_end_financial_year is not empty/falsey" do
      subject.project_end_financial_year = nil
      expect(subject.valid?).to be false
      expect(subject.errors[:project_end_financial_year]).to include
      "^Tell us the financial year when the project will stop spending funds."
    end

    # validates_numericality_of doesn't seem to work with multiple qualifiers
    # in this case :only_integer, :less_than and :greater_than
    it "validates the numericality of :project_end_financial_year" do
      subject.project_end_financial_year = "abc"
      expect(subject.valid?).to be false
      expect(subject.errors[:project_end_financial_year]).to include
      "^The financial year must be valid. For example, 2020."
    end

    it "validates that :project_end_financial_year is current financial year or later" do
      subject.project_end_financial_year = Time.current.uk_financial_year - 1
      current_financial_year = Time.current.uk_financial_year
      expect(subject.valid?).to be false
      expect(subject.errors[:project_end_financial_year]).to include
      "^Tell us the financial year when the project will stop spending funds."
    end

    it "validates that :project_end_financial_year is earlier than 2100" do
      subject.project_end_financial_year = 2101
      expect(subject.valid?).to be false
      expect(subject.errors[:project_end_financial_year]).to include
      "must be 2100 or earlier"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:financial_year_step) }
    let(:params) { HashWithIndifferentAccess.new({ financial_year_step: { project_end_financial_year: "2020" }})}
    let(:error_params) { HashWithIndifferentAccess.new({ financial_year_step: { project_end_financial_year: "1983" }})}

    it "saves the :project_end_financial_year if valid" do
      expect(subject.project_end_financial_year).not_to eq 2020
      expect(subject.update(params)).to be true
      expect(subject.project_end_financial_year).to eq 2020
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :financial_year
      subject.update(params)
      expect(subject.step).to eq :start_outline_business_case_date
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :financial_year
      subject.update(error_params)
      expect(subject.step).to eq :financial_year
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:financial_year_step) }

    it "should return :project_name" do
      expect(subject.previous_step).to eq :project_type
    end
  end

  describe "#financial_year_options" do
    subject { FactoryGirl.build(:financial_year_step) }

    it "should return the correct set of financial year options" do
      current_financial_year = Time.current.uk_financial_year
      expect(subject.financial_year_options).to eq current_financial_year..current_financial_year + 5
    end
  end
end
