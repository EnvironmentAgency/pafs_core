require 'rails_helper'

RSpec.describe PafsCore::Camc3Presenter do
  subject { described_class.new(project: project) }

  let(:project) { (FactoryGirl.create(:full_project, project_end_financial_year: 2027)) }
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

  describe '#households_at_reduced_risk' do
    it 'has the forecast for the households at reduced risks' do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          households_at_reduced_risk: hash[:value],
          financial_year: hash[:year]
        )
      end
      expect(subject.households_at_reduced_risk).to eql(outcome_measurements)
    end

  end
  describe '#moved_from_very_significant_and_significant_to_moderate_or_low' do
    it 'has the forecast for the households moved from very significant and significant to moderate or low' do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          moved_from_very_significant_and_significant_to_moderate_or_low: hash[:value],
          financial_year: hash[:year]
        )
      end
      expect(subject.moved_from_very_significant_and_significant_to_moderate_or_low).to eql(outcome_measurements)
    end
  end

  describe '#households_protected_from_loss_in_20_percent_most_deprived' do
    it 'has the forecast for the households protected from loss in 20 percent most deprived' do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          households_protected_from_loss_in_20_percent_most_deprived: hash[:value],
          financial_year: hash[:year]
        )
      end
      expect(subject.households_protected_from_loss_in_20_percent_most_deprived).to eql(outcome_measurements)
    end

  end
  describe '#coastal_households_at_reduced_risk' do
    it 'has the forecast for the coastal households at reduced risk' do
      funding_values.each do |hash|
        project.coastal_erosion_protection_outcomes.create(
          households_at_reduced_risk: hash[:value],
          financial_year: hash[:year]
        )
      end
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
