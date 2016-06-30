# frozen_string_literal: true
FactoryGirl.define do
  factory :funding_values, class: PafsCore::FundingValue do
    project_id 1
    financial_year 2020
    fcerm_gia 120000

    factory :previous_year do
      financial_year -1
    end
  end
end
