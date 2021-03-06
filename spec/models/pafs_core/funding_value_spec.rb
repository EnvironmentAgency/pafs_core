# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::FundingValue, type: :model do
  let(:project) do
    FactoryBot.create(
      :project,
      internal_drainage_boards: true,
      fcerm_gia: true,
      local_levy: true,
      not_yet_identified: true,
      growth_funding: true
    )
  end

  describe "attributes" do
    subject { FactoryBot.create(:funding_value) }

    it { is_expected.to validate_numericality_of(:fcerm_gia).allow_nil }
    it { is_expected.to validate_numericality_of(:local_levy).allow_nil }
    it { is_expected.to validate_numericality_of(:internal_drainage_boards).allow_nil }
    it { is_expected.to validate_numericality_of(:growth_funding).allow_nil }
    it { is_expected.to validate_numericality_of(:not_yet_identified).allow_nil }
  end

  describe ".previous_years" do
    before(:each) do
      @values = FactoryBot.create(:funding_value, :previous_year, project: project)
    end

    it "returns records with :financial_year set to -1" do
      records = described_class.previous_years
      expect(records.first).to eq @values
    end
  end

  describe ".to_financial_year" do
    before(:each) do
      @values = [
        FactoryBot.create(:funding_value, :previous_year, project: project),
        FactoryBot.create(:funding_value, project: project, financial_year: 2017),
        FactoryBot.create(:funding_value, project: project, financial_year: 2018),
        FactoryBot.create(:funding_value, project: project, financial_year: 2019)
      ]
    end

    it "returns records upto and including the specified year" do
      records = described_class.to_financial_year(2018)
      expect(records.count).to eq 3
      expect(records).to include *@values[0...-1]
    end
  end

  describe "saving" do
    subject do
      FactoryBot.build(
        :funding_value,
        project: project,
        fcerm_gia: 2_500_000,
        local_levy: 1_000_000,
        internal_drainage_boards: 100,
        growth_funding: 1_000,
        not_yet_identified: 2_500
      )
    end

    it "calculates the total" do
      expect { subject.save }.to change { subject.total }.to(3_503_600)
    end
  end
end
