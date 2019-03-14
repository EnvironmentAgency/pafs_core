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

  it "has a name" do
    expect(subject.name).to eql(presenter.name)
  end

  it "has a type" do
    expect(subject.type).to eql(presenter.project_type)
  end

  it "has national project number" do
    expect(subject.national_project_number).to eql(presenter.reference_number)
  end

  it "has pafs ons region" do
    expect(subject.pafs_ons_region).to eql(presenter.region)
  end

  it "has pafs region and coastal commitee" do
    expect(subject.pafs_region_and_coastal_commitee).to eql(presenter.rfcc)
  end

  it "has pafs ea area" do
    expect(subject.pafs_ea_area).to eql(presenter.ea_area)
  end

  it "pafs lrma name" do
    expect(subject.lrma_name).to eql(presenter.rma_name)
  end

  it "pafs lrma type" do
    expect(subject.lrma_type).to eql(presenter.rma_type)
  end

  it "pafs coastal group" do
    expect(subject.coastal_group).to eql(presenter.coastal_group)
  end

  it "risk source" do
    expect(subject.risk_source).to eql(presenter.main_risk)
  end

  it "moderation code" do
    expect(subject.moderation_code).to eql(presenter.moderation_code)
  end

  it "pafs county" do
    expect(subject.pafs_county).to eql(presenter.county)
  end


  it "earliest funding profile date" do
    expect(subject.earliest_funding_profile_date).to eql(presenter.earliest_start_date)
  end

  it "aspirational gateway 1" do
    expect(subject.aspirational_gateway_1).to eql(presenter.start_business_case_date)
  end

  it "aspirational gateway 3" do
    expect(subject.aspirational_gateway_3).to eql(presenter.award_contract_date)
  end

  it "aspirational start of construction" do
    expect(subject.aspirational_start_of_construction).to eql(presenter.start_construction_date)
  end

  it "aspirational gateway 4" do
    expect(subject.aspirational_gateway_4).to eql(presenter.ready_for_service_date)
  end

  it "problem and proposed solution" do
    expect(subject.problem_and_proposed_solution).to eql(presenter.approach)
  end

  it "flooding standard of protection before" do
    expect(subject.flooding_standard_of_protection_before).to eql(presenter.flood_protection_before)
  end

  it "flooding standard of protection after" do
    expect(subject.flooding_standard_of_protection_after).to eql(presenter.flood_protection_after)
  end

  it "coastal erosion standard of protection before" do
    expect(subject.coastal_erosion_standard_of_protection_before).to eql(presenter.coastal_protection_before)
  end

  it "coastal erosion standard of protection after" do
    expect(subject.coastal_erosion_standard_of_protection_after).to eql(presenter.coastal_protection_after)
  end

  it "strategic approach" do
    expect(subject.strategic_approach).to eql(presenter.strategic_approach)
  end

  it "duration of benefits" do
    expect(subject.duration_of_benefits).to eql(presenter.duration_of_benefits)
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
