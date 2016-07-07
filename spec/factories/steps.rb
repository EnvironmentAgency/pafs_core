# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
FactoryGirl.define do
  factory :basic_step, class: PafsCore::BasicStep do
    project
    initialize_with { new(project) }

    factory :project_name_step, class: PafsCore::ProjectNameStep do
      name "My fantastic flood prevention scheme"
    end

    factory :project_type_step, class: PafsCore::ProjectTypeStep do
      project_type PafsCore::PROJECT_TYPES.first
    end

    factory :financial_year_step, class: PafsCore::FinancialYearStep do
      project_end_financial_year 2018
    end

    factory :financial_year_alternative_step, class: PafsCore::FinancialYearAlternativeStep do
      project_end_financial_year 2022
    end

    factory :key_dates_step, class: PafsCore::KeyDatesStep do
      start_outline_business_case_month 2
      start_outline_business_case_year 2012
      award_contract_month 4
      award_contract_year 2014
      start_construction_month 5
      start_construction_year 2015
      ready_for_service_month 9
      ready_for_service_year 2019
    end

    factory :funding_sources_step, class: PafsCore::FundingSourcesStep do
      fcerm_gia true
      public_contributions true
      public_contributor_names "Mary, Mungo and Midge"
      funding_sources_visited true
    end

    factory :earliest_start_step, class: PafsCore::EarliestStartStep do
      could_start_early true
    end

    factory :earliest_date_step, class: PafsCore::EarliestDateStep do
      earliest_start_month 3
      earliest_start_year 2017
    end

    factory :risks_step, class: PafsCore::RisksStep do
      fluvial_flooding true
    end

    factory :main_risk_step, class: PafsCore::MainRiskStep do
      main_risk "fluvial_flooding"
    end

    factory :standard_of_protection_step, class: PafsCore::StandardOfProtectionStep do
      flood_protection_before 66
      flood_protection_after 23
    end

    factory :standard_of_protection_coastal_step, class: PafsCore::StandardOfProtectionCoastalStep do
      coastal_protection_before 10
      coastal_protection_after 30
    end

    factory :approach_step, class: PafsCore::ApproachStep do
      approach "We will go left and then turn right for a bit"
    end

    factory :surface_and_groundwater_step, class: PafsCore::SurfaceAndGroundwaterStep do
      improve_surface_or_groundwater true
    end

    factory :surface_and_groundwater_amount_step, class: PafsCore::SurfaceAndGroundwaterAmountStep do
      improve_surface_or_groundwater_amount 50.25
    end

    factory :improve_river_step, class: PafsCore::ImproveRiverStep do
      improve_river true
    end

    factory :improve_spa_or_sac_step, class: PafsCore::ImproveSpaOrSacStep do
      improve_spa_or_sac true
    end

    factory :improve_sssi_step, class: PafsCore::ImproveSssiStep do
      improve_sssi true
    end

    factory :improve_hpi_step, class: PafsCore::ImproveHpiStep do
      improve_hpi true
    end

    factory :improve_habitat_amount_step, class: PafsCore::ImproveHabitatAmountStep do
      improve_habitat_amount 1.23
    end

    factory :improve_river_amount_step, class: PafsCore::ImproveRiverAmountStep do
      improve_river_amount 21.7
    end

    factory :habitat_creation_step, class: PafsCore::HabitatCreationStep do
      create_habitat true
    end

    factory :habitat_creation_amount_step, class: PafsCore::HabitatCreationAmountStep do
      create_habitat_amount 2.5
    end

    factory :remove_fish_barrier_step, class: PafsCore::RemoveFishBarrierStep do
      remove_fish_barrier true
    end

    factory :remove_eel_barrier_step, class: PafsCore::RemoveEelBarrierStep do
      remove_eel_barrier true
    end

    factory :fish_or_eel_amount_step, class: PafsCore::FishOrEelAmountStep do
      fish_or_eel_amount 22
    end

    factory :urgency_step, class: PafsCore::UrgencyStep do
      urgency_reason "health_and_safety"
    end

    factory :urgency_details_step, class: PafsCore::UrgencyDetailsStep do
      urgency_details "This is the description"
    end

    factory :funding_calculator_step, class: PafsCore::FundingCalculatorStep do
      funding_calculator_file_name "pf_calc.xls"
    end

    factory :funding_calculator_summary_step, class: PafsCore::FundingCalculatorSummaryStep do
    end
  end
end
