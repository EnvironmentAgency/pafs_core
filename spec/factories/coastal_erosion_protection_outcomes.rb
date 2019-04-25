# frozen_string_literal: true
FactoryBot.define do
  factory :coastal_erosion_protection_outcomes, class: PafsCore::CoastalErosionProtectionOutcome do
    project_id { 1 }
    financial_year { 2020 }
    households_at_reduced_risk { 100 }
    households_protected_from_loss_in_next_20_years { 50 }
    households_protected_from_loss_in_20_percent_most_deprived { 25 }
  end
end
