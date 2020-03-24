# frozen_string_literal: true

FactoryBot.define do
  factory :funding_value, class: PafsCore::FundingValue do
    project
    financial_year { 2020 }
    fcerm_gia { 120_000 }
    local_levy { 101_010 }
    growth_funding { 505_050 }
    internal_drainage_boards { 606_060 }
    not_yet_identified { 707_070 }

    transient do
      public_contribution_names { [] }
      private_contribution_names { [] }
      other_ea_contribution_names { [] }
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
      %w[public private other_ea].each do |attr|
        names = builder.send("#{attr}_contribution_names")
        names.size.times do |i|
          create(
            :funding_contributor,
            "#{attr}_contributor".to_sym,
            funding_value: fv,
            name: names[i]
          )
        end
      end
    end

    trait :with_public_contributor do
      public_contribution_names { ["EnviroCo Ltd"] }
    end

    trait :with_private_contributor do
      private_contribution_names { ["EnviroCo Ltd"] }
    end

    trait :with_other_ea_contributor do
      other_ea_contribution_names { ["EnviroCo Ltd"] }
    end

    trait :previous_year do
      financial_year { -1 }
    end
  end
end
