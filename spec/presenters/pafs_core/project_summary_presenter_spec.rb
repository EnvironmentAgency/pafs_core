# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProjectSummaryPresenter do
  subject { PafsCore::ProjectSummaryPresenter.new(FactoryGirl.build(:project)) }

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

  describe "#location_set?" do
    context "when the location has been set" do
      it "returns true" do
        subject.grid_reference = "ST 58198 72725"
        expect(subject.location_set?).to eq true
      end
    end
    context "when the project location has not been set" do
      it "returns false" do
        subject.grid_reference = nil
        expect(subject.location_set?).to eq false
      end
    end
  end

  describe "#start_outline_business_case_date" do
    context "when the month and year are present" do
      it "combines the month and year fields into a formatted date string" do
        subject.start_outline_business_case_month = 3
        subject.start_outline_business_case_year = 2016
        expect(subject.start_outline_business_case_date).to eq "March 2016"
      end
    end

    context "when the month and year are not set" do
      it "returns the html string '<em>Not provided</em>'" do
        expect(subject.start_outline_business_case_date).to eq "<em>Not provided</em>"
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
      it "returns the html string '<em>Not provided</em>'" do
        expect(subject.award_contract_date).to eq "<em>Not provided</em>"
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
      it "returns the html string '<em>Not provided</em>'" do
        expect(subject.start_construction_date).to eq "<em>Not provided</em>"
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
      it "returns the html string '<em>Not provided</em>'" do
        expect(subject.ready_for_service_date).to eq "<em>Not provided</em>"
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
      it "returns the html string '<em>Not provided</em>'" do
        expect(subject.earliest_start_date).to eq "<em>Not provided</em>"
      end
    end
  end

  describe "#key_dates_started?" do
    context "when one or more important date has been set" do
      it "returns true when start_outline_business_case date set" do
        subject.start_outline_business_case_month = 3
        expect(subject.key_dates_started?).to eq true
      end
      it "returns true when award_contract set" do
        subject.award_contract_month = 5
        expect(subject.key_dates_started?).to eq true
      end
      it "returns true when start_construction date set" do
        subject.start_construction_month = 7
        expect(subject.key_dates_started?).to eq true
      end
      it "returns true when ready_for_service date set" do
        subject.ready_for_service_month = 9
        expect(subject.key_dates_started?).to eq true
      end
    end
    context "when none of the important dates have been set" do
      it "returns false" do
        expect(subject.key_dates_started?).to eq false
      end
    end
  end

  describe "#funding_sources_started?" do
    context "once the funding_sources page has been visited" do
      it "returns true" do
        subject.funding_sources_visited = true
        expect(subject.funding_sources_started?).to eq true
      end
    end
    context "before the user has completed the funding_sources" do
      it "returns false" do
        subject.funding_sources_visited = false
        expect(subject.funding_sources_started?).to eq false
      end
    end
  end

  describe "#earliest_start_started?" do
    context "when could_start_early has been set" do
      it "returns true" do
        subject.could_start_early = true
        expect(subject.earliest_start_started?).to eq true

        subject.could_start_early = false
        expect(subject.earliest_start_started?).to eq true
      end
    end
    context "when could_start_early has not been set" do
      it "returns false" do
        subject.could_start_early = nil
        expect(subject.earliest_start_started?).to eq false
      end
    end
  end

  describe "#risks_started?" do
    context "when risks have been selected" do
      it "returns true" do
        subject.fluvial_flooding = true
        expect(subject.risks_started?).to eq true
      end
    end

    context "when risks have not been selected" do
      it "returns false" do
        expect(subject.risks_started?).to eq false
      end
    end
  end

  describe "#standard_of_protection_started?" do
    context "when :flood_protection_before set" do
      it "returns true" do
        subject.flood_protection_before = 1
        expect(subject.standard_of_protection_started?).to eq true
      end
    end
    context "when :flood_protection_after set" do
      it "returns true" do
        subject.flood_protection_after = 1
        expect(subject.standard_of_protection_started?).to eq true
      end
    end
    context "when :coastal_protection_before set" do
      it "returns true" do
        subject.coastal_protection_before = 1
        expect(subject.standard_of_protection_started?).to eq true
      end
    end
    context "when :coastal_protection_after set" do
      it "returns true" do
        subject.coastal_protection_after = 1
        expect(subject.standard_of_protection_started?).to eq true
      end
    end
    context "when none of the standard of protection attributes have values" do
      it "returns false" do
        expect(subject.standard_of_protection_started?).to eq false
      end
    end
  end

  describe "#standard_of_protection_step" do
    context "when the project protects against flooding" do
      it "returns :standard_of_protection" do
        subject.fluvial_flooding = true
        expect(subject.standard_of_protection_step).to eq :standard_of_protection
      end
    end
    context "when the project does not protect against flooding" do
      context "when the project protects against coastal erosion" do
        it "returns :standard_of_protection_coastal" do
          subject.coastal_erosion = true
          expect(subject.standard_of_protection_step).to eq :standard_of_protection_coastal
        end
      end
      context "when the project does not protect against coastal erosion" do
        it "raises an error" do
          expect { subject.standard_of_protection_step }.
            to raise_error(RuntimeError, "Risks not set prior to standard of protection")
        end
      end
    end
  end

  describe "#flood_protection_before_percentage" do
    context "when :flood_protection_before is set" do
      it "looks up the value and returns the correct label" do
        (0..3).each do |n|
          subject.flood_protection_before = n.to_s
          expect(subject.flood_protection_before_percentage).to eq(flood_options[n])
        end
      end
    end
    context "when :flood_protection_before is nil" do
      it "returns not provided text" do
        expect(subject.flood_protection_before_percentage).to eq not_provided_text
      end
    end
  end

  describe "#flood_protection_after_percentage" do
    context "when :flood_protection_after is set" do
      it "looks up the value and returns the correct label" do
        (0..3).each do |n|
          subject.flood_protection_after = n.to_s
          expect(subject.flood_protection_after_percentage).to eq(flood_options[n])
        end
      end
    end
    context "when :flood_protection_after is nil" do
      it "returns not provided text" do
        expect(subject.flood_protection_after_percentage).to eq not_provided_text
      end
    end
  end

  describe "#coastal_protection_before_years" do
    context "when :coastal_protection_before is set" do
      it "looks up the value and returns the correct label" do
        (0..3).each do |n|
          subject.coastal_protection_before = n.to_s
          expect(subject.coastal_protection_before_years).to eq(coastal_before_options[n])
        end
      end
    end
    context "when :coastal_protection_before is nil" do
      it "returns not provided text" do
        expect(subject.coastal_protection_before_years).to eq not_provided_text
      end
    end
  end

  describe "#coastal_protection_after_years" do
    context "when :coastal_protection_after is set" do
      it "looks up the value and returns the correct label" do
        (0..3).each do |n|
          subject.coastal_protection_after = n.to_s
          expect(subject.coastal_protection_after_years).to eq(coastal_after_options[n])
        end
      end
    end
    context "when :coastal_protection_after is nil" do
      it "returns not provided text" do
        expect(subject.coastal_protection_after_years).to eq not_provided_text
      end
    end
  end

  describe "#flood_protection_outcomes_entered?" do
    context "when flood protection outcomes have been set" do
      it "returns true" do
        expect(subject).to receive(:flood_protection_outcomes) { [1, 2, 3] }
        expect(subject.flood_protection_outcomes_entered?).to eq true
      end
    end
    context "when flood protection outcomes have not been set" do
      it "returns false" do
        expect(subject.flood_protection_outcomes_entered?).to eq false
      end
    end
  end

  describe "#coastal_erosion_protection_outcomes_entered?" do
    context "when coastal erosion protection outcomes have been set" do
      it "returns true" do
        expect(subject).to receive(:coastal_erosion_protection_outcomes) { [1, 2, 3] }
        expect(subject.coastal_erosion_protection_outcomes_entered?).to eq true
      end
    end
    context "when coastal erosion protection outcomes have not been set" do
      it "returns false" do
        expect(subject.coastal_erosion_protection_outcomes_entered?).to eq false
      end
    end
  end

  describe "#environmental_outcomes_started?" do
    context "when :improve_surface_or_groundwater set" do
      it "returns true" do
        subject.improve_surface_or_groundwater = true
        expect(subject.environmental_outcomes_started?).to eq true
      end
    end
    context "when :improve_spa_or_sac set" do
      it "returns true" do
        subject.improve_spa_or_sac = true
        expect(subject.environmental_outcomes_started?).to eq true
      end
    end
    context "when :improve_sssi set" do
      it "returns true" do
        subject.improve_sssi = true
        expect(subject.environmental_outcomes_started?).to eq true
      end
    end
    context "when :improve_hpi set" do
      it "returns true" do
        subject.improve_hpi = true
        expect(subject.environmental_outcomes_started?).to eq true
      end
    end
    context "when :improve_river set" do
      it "returns true" do
        subject.improve_river = true
        expect(subject.environmental_outcomes_started?).to eq true
      end
    end
    context "when :create_habitat set" do
      it "returns true" do
        subject.create_habitat = true
        expect(subject.environmental_outcomes_started?).to eq true
      end
    end
    context "when :remove_fish_barrier set" do
      it "returns true" do
        subject.remove_fish_barrier = true
        expect(subject.environmental_outcomes_started?).to eq true
      end
    end
    context "when :remove_eel_barrier set" do
      it "returns true" do
        subject.remove_eel_barrier = true
        expect(subject.environmental_outcomes_started?).to eq true
      end
    end
    context "when none of the environmental outcomes attributes have values" do
      it "returns false" do
        expect(subject.standard_of_protection_started?).to eq false
      end
    end
  end

  describe "#surface_and_groundwater_size" do
    context "when it does not improve surface or ground water" do
      it "returns zero km" do
        subject.improve_surface_or_groundwater = false
        expect(subject.surface_and_groundwater_size).to eq "0 kilometres"
      end
    end
    context "when it does improve surface or ground water" do
      before(:each) { subject.improve_surface_or_groundwater = true }

      context "when an amount has been specified" do
        it "returns the amount suffixed with 'kilometres'" do
          subject.improve_surface_or_groundwater_amount = 20
          expect(subject.surface_and_groundwater_size).to eq "20 kilometres"
        end
      end

      context "when an amount has not been specified" do
        it "returns the text 'Not provided'" do
          subject.improve_surface_or_groundwater_amount = nil
          expect(subject.surface_and_groundwater_size).to eq not_provided_text
        end
      end
    end
  end

  describe "#improve_habitat_size" do
    context "when it does not improve habitat" do
      it "returns zero hectares" do
        subject.improve_spa_or_sac = false
        subject.improve_sssi = false
        subject.improve_hpi = false
        expect(subject.improve_habitat_size).to eq "0 hectares"
      end
    end
    context "when it does improve habitat" do
      before(:each) { subject.improve_spa_or_sac = true }

      context "when an amount has been specified" do
        it "returns the amount suffixed with 'hectares'" do
          subject.improve_habitat_amount = 123
          expect(subject.improve_habitat_size).to eq "123 hectares"
        end
      end

      context "when an amount has not been specified" do
        it "returns the text 'Not provided'" do
          subject.improve_habitat_amount = nil
          expect(subject.improve_habitat_size).to eq not_provided_text
        end
      end
    end
  end

  describe "#improve_river_size" do
    context "when it does not improve rivers" do
      it "returns zero km" do
        subject.improve_river = false
        expect(subject.improve_river_size).to eq "0 kilometres"
      end
    end
    context "when it does improve rivers" do
      before(:each) { subject.improve_river = true }

      context "when an amount has been specified" do
        it "returns the amount suffixed with 'kilometres'" do
          subject.improve_river_amount = 12.5
          expect(subject.improve_river_size).to eq "12.5 kilometres"
        end
      end

      context "when an amount has not been specified" do
        it "returns the text 'Not provided'" do
          subject.improve_river_amount = nil
          expect(subject.improve_river_size).to eq not_provided_text
        end
      end
    end
  end

  describe "#create_habitat_size" do
    context "when it does not create habitat" do
      it "returns zero hectares" do
        subject.create_habitat = false
        expect(subject.create_habitat_size).to eq "0 hectares"
      end
    end
    context "when it does create habitat" do
      before(:each) { subject.create_habitat = true }

      context "when an amount has been specified" do
        it "returns the amount suffixed with 'hectares'" do
          subject.create_habitat_amount = 123
          expect(subject.create_habitat_size).to eq "123 hectares"
        end
      end

      context "when an amount has not been specified" do
        it "returns the text 'Not provided'" do
          subject.create_habitat_amount = nil
          expect(subject.create_habitat_size).to eq not_provided_text
        end
      end
    end
  end

  describe "#fish_or_eel_passage_size" do
    context "when it does not remove fish or eel barriers" do
      it "returns zero km" do
        subject.remove_fish_barrier = false
        subject.remove_eel_barrier = false
        expect(subject.fish_or_eel_passage_size).to eq "0 kilometres"
      end
    end
    context "when it does removes fish barriers" do
      before(:each) { subject.remove_fish_barrier = true }

      context "when an amount has been specified" do
        it "returns the amount suffixed with 'kilometres'" do
          subject.fish_or_eel_amount = 43
          expect(subject.fish_or_eel_passage_size).to eq "43 kilometres"
        end
      end

      context "when an amount has not been specified" do
        it "returns the text 'Not provided'" do
          subject.fish_or_eel_amount = nil
          expect(subject.fish_or_eel_passage_size).to eq not_provided_text
        end
      end
    end
    context "when it removes eel barriers" do
      before(:each) { subject.remove_eel_barrier = true }

      context "when an amount has been specified" do
        it "returns the amount suffixed with 'kilometres'" do
          subject.fish_or_eel_amount = 3
          expect(subject.fish_or_eel_passage_size).to eq "3 kilometres"
        end
      end

      context "when an amount has not been specified" do
        it "returns the text 'Not provided'" do
          subject.fish_or_eel_amount = nil
          expect(subject.fish_or_eel_passage_size).to eq not_provided_text
        end
      end
    end
  end

  describe "#submission_date" do
    it "returns the text 'Proposal not submitted'" do
      expect(subject.submission_date).to eq "Proposal not submitted"
    end
  end

  describe "#total_for_flooding_a" do
    context "when flood protection outcomes have not been entered" do
      it "returns the text 'Not provided'" do
        expect(subject.total_for_flooding_a).to eq not_provided_text
      end
    end
    context "when flood protection outcomes have been entered" do
      before(:each) do
        subject.project_end_financial_year = 2035
        subject.save
        outcomes = [make_flood_outcome(2017, subject.id),
                    make_flood_outcome(2020, subject.id),
                    make_flood_outcome(2030, subject.id)]
        subject.flood_protection_outcomes << outcomes
        @total = outcomes.inject(0) { |sum, o| sum + o.households_at_reduced_risk }
      end

      it "returns the total for column A" do
        expect(subject.total_for_flooding_a).to eq @total
      end
    end
  end

  describe "#total_for_flooding_b" do
    context "when flood protection outcomes have not been entered" do
      it "returns the text 'Not provided'" do
        expect(subject.total_for_flooding_b).to eq not_provided_text
      end
    end
    context "when flood protection outcomes have been entered" do
      before(:each) do
        subject.project_end_financial_year = 2035
        subject.save
        outcomes = [make_flood_outcome(2017, subject.id),
                    make_flood_outcome(2020, subject.id),
                    make_flood_outcome(2030, subject.id)]
        subject.flood_protection_outcomes << outcomes
        @total = outcomes.inject(0) { |sum, o| sum + o.moved_from_very_significant_and_significant_to_moderate_or_low }
      end

      it "returns the total for column B" do
        expect(subject.total_for_flooding_b).to eq @total
      end
    end
  end

  describe "#total_for_flooding_c" do
    context "when flood protection outcomes have not been entered" do
      it "returns the text 'Not provided'" do
        expect(subject.total_for_flooding_c).to eq not_provided_text
      end
    end
    context "when flood protection outcomes have been entered" do
      before(:each) do
        subject.project_end_financial_year = 2035
        subject.save
        outcomes = [make_flood_outcome(2017, subject.id),
                    make_flood_outcome(2020, subject.id),
                    make_flood_outcome(2030, subject.id)]
        subject.flood_protection_outcomes << outcomes
        @total = outcomes.inject(0) { |sum, o| sum + o.households_protected_from_loss_in_20_percent_most_deprived }
      end

      it "returns the total for column C" do
        expect(subject.total_for_flooding_c).to eq @total
      end
    end
  end

  describe "#total_for_coastal_a" do
    context "when coastal erosion protection outcomes have not been entered" do
      it "returns the text 'Not provided'" do
        expect(subject.total_for_coastal_a).to eq not_provided_text
      end
    end
    context "when coastal erosion protection outcomes have been entered" do
      before(:each) do
        subject.project_end_financial_year = 2035
        subject.save
        outcomes = [make_coastal_outcome(2017, subject.id),
                    make_coastal_outcome(2020, subject.id),
                    make_coastal_outcome(2030, subject.id)]
        subject.coastal_erosion_protection_outcomes << outcomes
        @total = outcomes.inject(0) { |sum, o| sum + o.households_at_reduced_risk }
      end

      it "returns the total for column A" do
        expect(subject.total_for_coastal_a).to eq @total
      end
    end
  end

  describe "#total_for_coastal_b" do
    context "when coastal erosion protection outcomes have not been entered" do
      it "returns the text 'Not provided'" do
        expect(subject.total_for_coastal_b).to eq not_provided_text
      end
    end
    context "when coastal erosion protection outcomes have been entered" do
      before(:each) do
        subject.project_end_financial_year = 2035
        subject.save
        outcomes = [make_coastal_outcome(2017, subject.id),
                    make_coastal_outcome(2020, subject.id),
                    make_coastal_outcome(2030, subject.id)]
        subject.coastal_erosion_protection_outcomes << outcomes
        @total = outcomes.inject(0) { |sum, o| sum + o.households_protected_from_loss_in_next_20_years }
      end

      it "returns the total for column B" do
        expect(subject.total_for_coastal_b).to eq @total
      end
    end
  end

  describe "#total_for_coastal_c" do
    context "when coastal erosion protection outcomes have not been entered" do
      it "returns the text 'Not provided'" do
        expect(subject.total_for_coastal_c).to eq not_provided_text
      end
    end
    context "when coastal erosion protection outcomes have been entered" do
      before(:each) do
        subject.project_end_financial_year = 2035
        subject.save
        outcomes = [make_coastal_outcome(2017, subject.id),
                    make_coastal_outcome(2020, subject.id),
                    make_coastal_outcome(2030, subject.id)]
        subject.coastal_erosion_protection_outcomes << outcomes
        @total = outcomes.inject(0) { |sum, o| sum + o.households_protected_from_loss_in_20_percent_most_deprived }
      end

      it "returns the total for column C" do
        expect(subject.total_for_coastal_c).to eq @total
      end
    end
  end

  describe "#funding_calculator_uploaded?" do
    context "when a file has been uploaded" do
      it "returns true" do
        subject.funding_calculator_file_name = "wigwam.xls"
        expect(subject.funding_calculator_uploaded?).to eq true
      end
    end
    context "when a file has not been uploaded" do
      it "returns false" do
        subject.funding_calculator_file_name = nil
        expect(subject.funding_calculator_uploaded?).to eq false
      end
    end
  end

  describe "#summary_label" do
    it "returns the text associated with the :symbol" do
      expect(subject.summary_label(:standard_of_protection_title)).
        to eq "Standard of protection"
    end
  end

  describe "#articles" do
    context "when project protects households" do
      before(:each) { subject.project_type = "CM" }
      context "when risks have been entered" do
        it "returns the list of articles" do
          subject.fluvial_flooding = true
          expect(subject.articles).to eq subject.send(:all_articles)
        end
      end
      context "when risks have not been entered" do
        it "returns the list of articles without :standard_of_protection" do
          expect(subject.articles).not_to include :standard_of_protection
        end
      end
    end
    context "when project does not protect households" do
      it "should return the list or articles without :risks or :standard_of_protection" do
        subject.project_type = "ENV_WITHOUT_HOUSEHOLDS"
        expect(subject.articles).not_to include [:risks, :standard_of_protection]
      end
    end
  end

  describe "#funding" do
    it "returns an array of hashes, one for each selected funding source" do
      expect(subject.funding).to eq []
      count = 0
      PafsCore::FundingSources::FUNDING_SOURCES.each do |fs|
        subject.send("#{fs}=", true)
        count += 1
        entry = { name: subject.funding_source_label(fs), value: subject.total_for(fs) }
        list = subject.funding
        expect(list).to include entry
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
