# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
FactoryGirl.define do
  factory :step, class: PafsCore::BasicStep do
    project
    initialize_with { new(project) }

    factory :project_name_step, class: PafsCore::ProjectNameStep do
      name "My fantastic flood prevention scheme"
    end

    factory :financial_year_step, class: PafsCore::FinancialYearStep do
      project_end_financial_year 2018
    end
  end
end
