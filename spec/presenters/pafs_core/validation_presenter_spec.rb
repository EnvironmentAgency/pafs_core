# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ValidationPresenter do
  subject { PafsCore::ValidationPresenter.new(FactoryGirl.build(:project)) }

  let(:flood_options) do
    ["Very significant",
     "Significant",
     "Moderate",
     "Low"]
  end
  let(:coastal_before_options) do
    ["Less than 1 year",
     "1 to 4 years",
     "5 to 9 years",
     "10 years or more"]
  end
  let(:coastal_after_options) do
    ["Less than 10 years",
     "10 to 19 years",
     "20 to 49 years",
     "50 years or more"]
  end

  let(:not_provided_text) { "<em>Not provided</em>" }

  describe "#project_name_complete?" do
    it "always returns true" do
      expect(subject.project_name_complete?).to eq true
    end
  end

  describe "#project_type_complete?" do
    it "always returns true" do
      expect(subject.project_type_complete?).to eq true
    end
  end

  describe "#financial_year_complete?" do
    it "always returns true" do
      expect(subject.financial_year_complete?).to eq true
    end
  end

  describe "#location_complete?" do
    context "when location has been set" do
      it "returns true" do
        subject.project_location = { latitude: "123", longitude: "123"}.to_json
        expect(subject.location_complete?).to eq true
      end
    end
    context "when location has not been set" do
      before(:each) { subject.project_location = nil }
      it "returns false" do
        expect(subject.location_complete?).to eq false
      end
      it "sets an error on the project" do
        subject.location_complete?
        expect(subject.errors[:location]).to include "^Tell us the location of the project"
      end
    end
  end

  describe "#key_dates_complete?" do
    before(:each) do
      subject.start_outline_business_case_month = 12
      subject.start_outline_business_case_year = 2016
      subject.award_contract_month = 12
      subject.award_contract_year = 2017
      subject.start_construction_month = 12
      subject.start_construction_year = 2018
      subject.ready_for_service_month = 12
      subject.ready_for_service_year = 2019
    end

    context "when the key dates are all present" do
      it "returns true" do
        expect(subject.key_dates_complete?).to eq true
      end
    end

    context "when one of the key dates is missing" do
      let(:dates) do
        [:start_outline_business_case_month,
         :award_contract_month,
         :start_construction_month,
         :ready_for_service_month]
      end

      it "returns false" do
        dates.each do |date|
          m = "#{date}="
          subject.send(m, nil)
          expect(subject.key_dates_complete?).to eq false
          subject.send(m, 12)
        end
      end

      it "sets an error message" do
        dates.each do |date|
          m = "#{date}="
          subject.send(m, nil)
          subject.key_dates_complete?
          expect(subject.errors[:key_dates]).to include "^Tell us the project's important dates"
          subject.send(m, 12)
        end
      end
    end
  end

  describe "#funding_sources_complete?"

  describe "#earliest_start_complete?" do
    context "when could_start_early is nil" do
      it "returns false" do
        subject.could_start_early = nil
        expect(subject.earliest_start_complete?).to eq false
      end
    end

    context "when could_start_early is true" do
      before(:each) { subject.could_start_early = true }

      context "when earliest_start_year is present" do
        it "returns true" do
          subject.earliest_start_month = 2
          subject.earliest_start_year = 2017
          expect(subject.earliest_start_complete?).to eq true
        end
      end

      context "when earliest_start_year is not present" do
        it "returns false" do
          subject.earliest_start_month = nil
          subject.earliest_start_year = nil
          expect(subject.earliest_start_complete?).to eq false
        end
      end
    end

    context "when could_start_early is false" do
      before(:each) { subject.could_start_early = false }

      it "returns true" do
        expect(subject.earliest_start_complete?).to eq true
      end
    end
  end

  describe "#risks_complete?" do
    context "when no risks have been selected" do
      before(:each) do
        PafsCore::Risks::RISKS.each do |r|
          subject.send("#{r}=", nil)
        end
      end

      it "returns false" do
        expect(subject.risks_complete?).to eq false
      end

      it "sets an error message" do
        subject.risks_complete?
        expect(subject.errors[:risks]).to include "^Tell us the risks the project"\
          " protects against and the households benefiting."
      end
    end

    context "when risks are selected" do
      before(:each) do
        PafsCore::Risks::RISKS.each do |r|
          subject.send("#{r}=", nil)
        end
        subject.fluvial_flooding = true
        subject.flood_protection_outcomes << FactoryGirl.build(:flood_protection_outcomes)
      end

      context "when a single risk is selected" do
        it "returns true" do
          expect(subject.risks_complete?).to eq true
        end
      end

      context "when multiple risks are selected" do
        before(:each) { subject.tidal_flooding = true }
        context "when a main risk is set" do
          before(:each) { subject.main_risk = "tidal_flooding" }
          it "returns true" do
            expect(subject.risks_complete?).to eq true
          end
        end

        context "when a main risk has not been set" do
          before(:each) { subject.main_risk = nil }
          it "returns false" do
            expect(subject.risks_complete?).to eq false
          end

          it "sets an error message" do
            subject.risks_complete?
            expect(subject.errors[:risks]).to include "^Tell us the risks the "\
              "project protects against and the households benefiting."
          end
        end
      end
    end
  end

  describe "#standard_of_protection_complete?"

  describe "#approach_complete?"

  describe "#environmental_outcomes_complete?"

  describe "#urgency_complete?"

  describe "#funding_calculator_complete?"

  def make_flood_outcome(year, project_id)
    FactoryGirl.create(:flood_protection_outcomes,
                       financial_year: year,
                       project_id: project_id)
  end

  def make_coastal_outcome(year, project_id)
    FactoryGirl.create(:coastal_erosion_protection_outcomes,
                       financial_year: year,
                       project_id: project_id)
  end
end
