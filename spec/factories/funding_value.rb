# frozen_string_literal: true
FactoryBot.define do
  factory :funding_value, class: PafsCore::FundingValue do
    project
    financial_year { 2020 }
    fcerm_gia { 120000 }
    local_levy { 101010 }
    growth_funding { 505050 }
    internal_drainage_boards { 606060 }
    not_yet_identified { 707070 }

    trait :with_public_contributor do
      after(:create) do |fv|
        create(:funding_contributor, :public_contributor, funding_value: fv)
      end
    end

    trait :with_private_contributor do
      after(:create) do |fv|
        create(:funding_contributor, :private_contributor, funding_value: fv)
      end
    end

    trait :with_other_ea_contributor do
      after(:create) do |fv|
        create(:funding_contributor, :other_ea_contributor, funding_value: fv)
      end
    end

    trait :previous_year do
      financial_year { -1 }
    end
  end
end
