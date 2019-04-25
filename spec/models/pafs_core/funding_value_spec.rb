# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FundingValue, type: :model do
  describe "attributes" do
    subject { FactoryBot.create(:funding_values) }

    it { is_expected.to validate_numericality_of(:fcerm_gia).allow_nil }
    it { is_expected.to validate_numericality_of(:local_levy).allow_nil }
    it { is_expected.to validate_numericality_of(:internal_drainage_boards).allow_nil }
    it { is_expected.to validate_numericality_of(:public_contributions).allow_nil }
    it { is_expected.to validate_numericality_of(:private_contributions).allow_nil }
    it { is_expected.to validate_numericality_of(:other_ea_contributions).allow_nil }
    it { is_expected.to validate_numericality_of(:growth_funding).allow_nil }
    it { is_expected.to validate_numericality_of(:not_yet_identified).allow_nil }
  end

  describe ".previous_years" do
    before(:each) do
      @project = FactoryBot.create(:project)
      @values = FactoryBot.create(:previous_year, project_id: @project.id)
    end
    it "returns records with :financial_year set to -1" do
      records = described_class.previous_years
      expect(records.first).to eq @values
    end
  end

  describe ".to_financial_year" do
    before(:each) do
      @project = FactoryBot.create(:project)
      @values = [
        FactoryBot.create(:previous_year, project_id: @project.id),
        FactoryBot.create(:funding_values, project_id: @project.id, financial_year: 2017),
        FactoryBot.create(:funding_values, project_id: @project.id, financial_year: 2018),
        FactoryBot.create(:funding_values, project_id: @project.id, financial_year: 2019)
      ]
    end
    it "returns records upto and including the specified year" do
      records = described_class.to_financial_year(2018)
      expect(records.count).to eq 3
      expect(records).to include *@values[0...-1]
    end
  end

  it "calculates the total before saving" do
    values = FactoryBot.build(:funding_values)
    values.fcerm_gia = 2_500_000
    values.local_levy = 1_000_000
    expect { values.save }.to change { values.total }.to(3_500_000)
  end
end
