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

    transient do
      public_contribution_count { 0 }
      private_contribution_count { 0 }
      other_ea_contribution_count { 0 }
      create_funding_values { false }
    end

    trait :blank do
      fcerm_gia { nil }
      local_levy { nil }
      growth_funding { nil }
      internal_drainage_boards { nil }
      not_yet_identified { nil }
    end

    after(:create) do |fv, builder|
      create_list(
        :funding_contributor, 
        builder.public_contribution_count,
        :public_contributor,
        funding_value: fv
      )

      create_list(
        :funding_contributor, 
        builder.private_contribution_count, 
        :private_contributor,
        funding_value: fv
      )

      create_list(
        :funding_contributor, 
        builder.other_ea_contribution_count, 
        :other_ea_contributor, 
        funding_value: fv
      )
    end

    trait :with_public_contributor do
      public_contribution_count { 1 }
    end

    trait :with_private_contributor do
      private_contribution_count { 1 }
    end

    trait :with_other_ea_contributor do
      other_ea_contribution_count { 1 }
    end

    trait :previous_year do
      financial_year { -1 }
    end
  end
end
