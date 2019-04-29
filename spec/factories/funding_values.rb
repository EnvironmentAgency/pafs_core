# frozen_string_literal: true
FactoryBot.define do
  factory :funding_values, class: PafsCore::FundingValue do
    project_id { 1 }
    financial_year { 2020 }
    fcerm_gia { 120000 }

    factory :previous_year do
      financial_year { -1 }
    end

    factory :full_funding_values do
      local_levy { 101010 }
      public_contributions { 202020 }
      private_contributions { 303030 }
      other_ea_contributions { 404040 }
      growth_funding { 505050 }
      internal_drainage_boards { 606060 }
      not_yet_identified { 707070 }
    end
  end
end
