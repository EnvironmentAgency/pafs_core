# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
FactoryGirl.define do
  factory :basic_step, class: PafsCore::BasicStep do
    project
    initialize_with { new(project) }

    factory :project_name_step, class: PafsCore::ProjectNameStep do
      name "My fantastic flood prevention scheme"
    end

    factory :financial_year_step, class: PafsCore::FinancialYearStep do
      project_end_financial_year 2018
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
  end
end
