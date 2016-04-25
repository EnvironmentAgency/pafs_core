# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProjectSummaryPresenter do
  subject { PafsCore::ProjectSummaryPresenter.new(FactoryGirl.build(:project)) }

  describe "#project_type_name" do
    context "when a :project_type is present" do
      it "returns a name for the project type" do
        subject.project_type = "cm"
        expect(subject.project_type_name).to eq "Capital Maintenance"
      end
    end

    context "when :project_type is not present" do
      it "returns an empty string" do
        subject.project_type = nil
        expect(subject.project_type_name).to eq ""
      end
    end
  end

  describe "#start_outline_business_case_date" do
    it "combines the month and year fields into a formatted date string" do
      subject.start_outline_business_case_month = 3
      subject.start_outline_business_case_year = 2016
      expect(subject.start_outline_business_case_date).to eq "March 2016"
    end
  end

  describe "#award_contract_date" do
    it "combines the month and year fields into a formatted date string" do
      subject.award_contract_month = 11
      subject.award_contract_year = 2017
      expect(subject.award_contract_date).to eq "November 2017"
    end
  end

  describe "#start_construction_date" do
    it "combines the month and year fields into a formatted date string" do
      subject.start_construction_month = 2
      subject.start_construction_year = 2018
      expect(subject.start_construction_date).to eq "February 2018"
    end
  end

  describe "#ready_for_service_date" do
    it "combines the month and year fields into a formatted date string" do
      subject.ready_for_service_month = 7
      subject.ready_for_service_year = 2019
      expect(subject.ready_for_service_date).to eq "July 2019"
    end
  end

  describe "#funding_sources" do
    it "returns an array of strings, one for each selected funding source" do
      expect(subject.funding_sources).to eq []
      subject.fcerm_gia = true
      expect(subject.funding_sources).to include "FCERM GiA"
      expect(subject.funding_sources.count).to eq 1
      subject.local_levy = true
      expect(subject.funding_sources).to include "Local levy"
      expect(subject.funding_sources.count).to eq 2
      subject.internal_drainage_boards = true
      expect(subject.funding_sources).to include "Internal drainage boards"
      expect(subject.funding_sources.count).to eq 3
      subject.public_contributions = true
      expect(subject.funding_sources).to include "Public contributions"
      expect(subject.funding_sources.count).to eq 4
      subject.private_contributions = true
      expect(subject.funding_sources).to include "Private contributions"
      expect(subject.funding_sources.count).to eq 5
      subject.other_ea_contributions = true
      expect(subject.funding_sources).to include "Other EA contributions"
      expect(subject.funding_sources.count).to eq 6
      subject.growth_funding = true
      expect(subject.funding_sources).to include "Growth funding"
      expect(subject.funding_sources.count).to eq 7
      subject.not_yet_identified = true
      expect(subject.funding_sources).to include "Not yet identified"
      expect(subject.funding_sources.count).to eq 8
    end
  end

  describe "#risks" do
    it "returns an array of symbols representing the selected risks" do
      expect(subject.risks).to eq []
      subject.fluvial_flooding = true
      expect(subject.risks.count).to eq 1
      expect(subject.risks).to include :fluvial_flooding
      subject.tidal_flooding = true
      expect(subject.risks.count).to eq 2
      expect(subject.risks).to include :tidal_flooding
      subject.groundwater_flooding = true
      expect(subject.risks.count).to eq 3
      expect(subject.risks).to include :groundwater_flooding
      subject.surface_water_flooding = true
      expect(subject.risks.count).to eq 4
      expect(subject.risks).to include :surface_water_flooding
      subject.coastal_erosion = true
      expect(subject.risks.count).to eq 5
      expect(subject.risks).to include :coastal_erosion
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

  describe "#early_start_date_or_no" do
    context "when the project could start early" do
      before(:each) { subject.could_start_early = true }

      context "when :earliest_start_month and year are present" do
        it "returns the earliest start date as a formatted string" do
          subject.earliest_start_month = 1
          subject.earliest_start_year = 2017
          expect(subject.early_start_date_or_no).to eq "January 2017"
        end
      end
      context "when the earliest start month and year are not set" do
        it "returns the string 'not set'" do
          expect(subject.early_start_date_or_no).to eq "not set"
        end
      end
    end

    context "when the project cannot start early" do
      it "returns the string 'No'" do
        subject.could_start_early = false
        expect(subject.early_start_date_or_no).to eq "No"
      end
    end
  end
end
