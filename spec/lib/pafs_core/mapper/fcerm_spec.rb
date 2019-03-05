require 'rails_helper'

RSpec.describe PafsCore::Mapper::Fcerm1 do
  subject { PafsCore::Mapper::Fcerm1.new(project: presenter) }

  let(:project) { (FactoryGirl.create(:full_project)) }
  let(:presenter) { PafsCore::SpreadsheetPresenter.new(project) }
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

  describe "#households_at_reduced_risk" do
    before(:each) do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          households_at_reduced_risk: hash[:value],
          financial_year: hash[:year]
        )
      end
    end

    it "returns a value for the given year" do
      funding_years.each do |year|
        expect(subject.households_at_reduced_risk(year)).to be_an(Integer)
      end
    end
  end

  describe "#moved_from_very_significant_and_significant_to_moderate_or_low" do
    before(:each) do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          moved_from_very_significant_and_significant_to_moderate_or_low: hash[:value],
          financial_year: hash[:year]
        )
      end
    end

    it "returns a value for the given year" do
      funding_years.each do |year|
        expect(subject.moved_from_very_significant_and_significant_to_moderate_or_low(year)).to be_an(Integer)
      end
    end
  end

  describe "#households_protected_from_loss_in_20_percent_most_deprived" do
    before(:each) do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          households_protected_from_loss_in_20_percent_most_deprived: hash[:value],
          financial_year: hash[:year]
        )
      end
    end

    it "returns a value for the given year" do
      funding_years.each do |year|
        expect(subject.households_protected_from_loss_in_20_percent_most_deprived(year)).to be_an(Integer)
      end
    end
  end

  describe "#coastal_households_at_reduced_risk" do
    before(:each) do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          households_at_reduced_risk: hash[:value],
          financial_year: hash[:year]
        )
      end
    end

    it "returns a value for the given year" do
      funding_years.each do |year|
        expect(subject.coastal_households_at_reduced_risk(year)).to be_an(Integer)
      end
    end
  end

  describe "#coastal_households_protected_from_loss_in_next_20_years" do
    before(:each) do
      funding_values.each do |hash|
        project.flood_protection_outcomes.create(
          households_protected_from_loss_in_20_percent_most_deprived: hash[:value],
          financial_year: hash[:year]
        )
      end
    end

    it "returns a value for the given year" do
      funding_years.each do |year|
        expect(subject.coastal_households_protected_from_loss_in_20_percent_most_deprived(year)).to be_an(Integer)
      end
    end
  end
end
