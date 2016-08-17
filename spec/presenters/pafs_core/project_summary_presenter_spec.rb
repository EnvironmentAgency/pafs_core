# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProjectSummaryPresenter do
  subject { PafsCore::ProjectSummaryPresenter.new(FactoryGirl.build(:project)) }

  describe "#start_outline_business_case_date" do
    context "when the month and year are present" do
      it "combines the month and year fields into a formatted date string" do
        subject.start_outline_business_case_month = 3
        subject.start_outline_business_case_year = 2016
        expect(subject.start_outline_business_case_date).to eq "March 2016"
      end
    end

    context "when the month and year are not set" do
      it "returns the string 'not set'" do
        expect(subject.start_outline_business_case_date).to eq "not set"
      end
    end
  end

  describe "#award_contract_date" do
    context "when the month and year are present" do
      it "combines the month and year fields into a formatted date string" do
        subject.award_contract_month = 11
        subject.award_contract_year = 2017
        expect(subject.award_contract_date).to eq "November 2017"
      end
    end

    context "when the month and year are not set" do
      it "returns the string 'not set'" do
        expect(subject.award_contract_date).to eq "not set"
      end
    end
  end

  describe "#start_construction_date" do
    context "when the month and year are present" do
      it "combines the month and year fields into a formatted date string" do
        subject.start_construction_month = 2
        subject.start_construction_year = 2018
        expect(subject.start_construction_date).to eq "February 2018"
      end
    end

    context "when the month and year are not set" do
      it "returns the string 'not set'" do
        expect(subject.start_construction_date).to eq "not set"
      end
    end
  end

  describe "#ready_for_service_date" do
    context "when the month and year are present" do
      it "combines the month and year fields into a formatted date string" do
        subject.ready_for_service_month = 7
        subject.ready_for_service_year = 2019
        expect(subject.ready_for_service_date).to eq "July 2019"
      end
    end

    context "when the month and year are not set" do
      it "returns the string 'not set'" do
        expect(subject.ready_for_service_date).to eq "not set"
      end
    end
  end

  describe "#earliest_start_date" do
    context "when the month and year are present" do
      it "combines the month and year fields into a formatted date string" do
        subject.earliest_start_month = 2
        subject.earliest_start_year = 2018
        expect(subject.earliest_start_date).to eq "February 2018"
      end
    end

    context "when the month and year are not set" do
      it "returns the string 'not set'" do
        expect(subject.earliest_start_date).to eq "not set"
      end
    end
  end

  describe "#selected_funding_sources" do
    it "returns an array of symbols, one for each selected funding source" do
      expect(subject.selected_funding_sources).to eq []
      count = 0
      PafsCore::FundingSources::FUNDING_SOURCES.each do |fs|
        subject.send("#{fs}=", true)
        count += 1
        list = subject.selected_funding_sources
        expect(list).to include fs
        expect(list.count).to eq count
      end
    end
  end

  describe "#risks" do
    it "returns an array of symbols representing the selected risks" do
      expect(subject.selected_risks).to eq []
      count = 0
      PafsCore::Risks::RISKS.each do |r|
        subject.send("#{r}=", true)
        count += 1
        list = subject.selected_risks
        expect(list).to include r
        expect(list.count).to eq count
      end
    end
  end

  describe "#is_main_risk?" do
    before(:each) do
      subject.surface_water_flooding = true
      subject.groundwater_flooding = true
      subject.main_risk = :groundwater_flooding
    end

    context "when the param equals the :main_risk" do
      it "returns true" do
        expect(subject.is_main_risk?(:groundwater_flooding)).to be true
      end
    end

    context "when the param is not equal to the :main_risk" do
      it "returns false" do
        expect(subject.is_main_risk?(:surface_water_flooding)).to be false
        expect(subject.is_main_risk?(:coastal_erosion)).to be false
        expect(subject.is_main_risk?(nil)).to be false
        expect(subject.is_main_risk?(:discarded_false_teeth)).to be false
      end
    end
  end
end
