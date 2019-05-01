require 'rails_helper'

RSpec.describe PafsCore::Camc3Presenter do
  subject { described_class.new(project: project) }

  let(:project) do
    FactoryBot.create(
      :full_project,
      {
        project_end_financial_year: 2027,
        funding_calculator_file_name: calculator_file
      }
    )
  end

  let(:calculator_file) do
    "calculator.xlsx"
  end

  let(:funding_values) do
    [
      {year: -1, value: 2000},
      {year: 2015, value: 200,},
      {year: 2016, value: 250,},
      {year: 2017, value: 350,},
      {year: 2018, value: 1250,},
      {year: 2019, value: 650,},
    ]
  end
  let(:funding_years) do
    [
      -1,
      2015,
      2016,
      2017,
      2018,
      2019,
      2020
    ]
  end

  let(:outcome_measurements) do
    [
      { year: -1,   value: 2000 },
      { year: 2015, value: 200 },
      { year: 2016, value: 250 },
      { year: 2017, value: 350 },
      { year: 2018, value: 1250 },
      { year: 2019, value: 650 },
      { year: 2020, value: 0 },
      { year: 2021, value: 0 },
      { year: 2022, value: 0 },
      { year: 2023, value: 0 },
      { year: 2024, value: 0 },
      { year: 2025, value: 0 },
      { year: 2026, value: 0 },
      { year: 2027, value: 0 },
      { year: 2028, value: 0 },
    ]
  end

  before(:each) do
    allow_any_instance_of(PafsCore::Files)
      .to receive(:fetch_funding_calculator_for)
      .with(project)
      .and_return(File.open(File.join(Rails.root, '..', 'fixtures', calculator_file)))
  end

  describe 'urgency_details' do
    it 'renders in the generated json' do
      expect(subject.attributes).to have_key(:urgency_details)
    end
  end

  describe '#households_at_reduced_risk' do
    before(:each) do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          households_at_reduced_risk: hash[:value],
          financial_year: hash[:year]
        )
      end
    end

    it 'has the forecast for the households at reduced risks' do
      expect(subject.households_at_reduced_risk).to eql(outcome_measurements)
    end

  end
  describe '#moved_from_very_significant_and_significant_to_moderate_or_low' do
    before(:each) do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          moved_from_very_significant_and_significant_to_moderate_or_low: hash[:value],
          financial_year: hash[:year]
        )
      end
    end

    it 'has the forecast for the households moved from very significant and significant to moderate or low' do
      expect(subject.moved_from_very_significant_and_significant_to_moderate_or_low).to eql(outcome_measurements)
    end
  end

  describe '#households_protected_from_loss_in_20_percent_most_deprived' do
    before(:each) do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          households_protected_from_loss_in_20_percent_most_deprived: hash[:value],
          financial_year: hash[:year]
        )
      end
    end

    it 'has the forecast for the households protected from loss in 20 percent most deprived' do
      expect(subject.households_protected_from_loss_in_20_percent_most_deprived).to eql(outcome_measurements)
    end

  end
  describe '#coastal_households_at_reduced_risk' do
    before(:each) do
      funding_values.each do |hash|
        project.coastal_erosion_protection_outcomes.create(
          households_at_reduced_risk: hash[:value],
          financial_year: hash[:year]
        )
      end
    end

    it 'has the forecast for the coastal) households at reduced risk' do
      expect(subject.coastal_households_at_reduced_risk).to eql(outcome_measurements)
    end
  end

  describe '#coastal_households_protected_from_loss_in_20_percent_most_deprived' do
    before(:each) do
      funding_values.each do |hash|
        project.coastal_erosion_protection_outcomes.create(
          households_protected_from_loss_in_20_percent_most_deprived: hash[:value],
          financial_year: hash[:year]
        )
      end
    end

    it 'should collect a forecast over 13 years' do
      expect(subject.coastal_households_protected_from_loss_in_20_percent_most_deprived).to eql(outcome_measurements)
    end
  end
end
