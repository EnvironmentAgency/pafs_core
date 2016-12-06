# frozen_string_literal: true
module PafsCore
  module Outcomes
    delegate :flood_protection_outcomes,
             :flood_protection_outcomes=,
             :flood_protection_outcomes_attributes=,
             :coastal_erosion_protection_outcomes,
             :coastal_erosion_protection_outcomes=,
             :coastal_erosion_protection_outcomes_attributes=,
             :project_end_financial_year,
             to: :project

    def current_flood_protection_outcomes
      # if this is a db query we lose inputted data when there are errors
      # and we send the user back to fix it
      flood_protection_outcomes.select do |fpo|
        fpo.financial_year <= project_end_financial_year
      end.sort_by(&:financial_year)
    end

    def current_coastal_erosion_protection_outcomes
      # if this is a db query we lose inputted data when there are errors
      # and we send the user back to fix it
      coastal_erosion_protection_outcomes.select do |cepo|
        cepo.financial_year <= project_end_financial_year
      end.sort_by(&:financial_year)
    end

    def total_fpo_for(value)
      current_flood_protection_outcomes.reduce(0) { |sum, fpo| sum + (fpo.send(value) || 0) }
    end

    def total_ce_for(value)
      current_coastal_erosion_protection_outcomes.reduce(0) { |sum, cepo| sum + (cepo.send(value) || 0) }
    end

    def total_protected_households
      flood_protection_outcomes.map(&:households_at_reduced_risk).compact.sum
    end
  end
end
