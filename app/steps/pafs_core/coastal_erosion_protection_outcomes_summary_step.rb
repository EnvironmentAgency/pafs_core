# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class CoastalErosionProtectionOutcomesSummaryStep < BasicStep

    delegate :coastal_erosion_protection_outcomes,
             :coastal_erosion_protection_outcomes=,
             :project_end_financial_year,
             :coastal_erosion?,
             :project_type, :project_protects_households?,
             to: :project

    def update(params)
      # just progress to next step
      @step = :standard_of_protection
      true
    end

    def previous_step
      :coastal_erosion_protection_outcomes
    end

    def step
      @step ||= :coastal_erosion_protection_outcomes_summary
    end

    def disabled?
      !(coastal_erosion? && !project_end_financial_year.nil? && project_protects_households?)
    end

    def completed?
      !!(coastal_erosion? && !total_protected_households.zero? && !total_for(:households_at_reduced_risk).zero?)
    end

    def current_coastal_erosion_protection_outcomes
      cepos = coastal_erosion_protection_outcomes.select { |cepo| cepo.financial_year <= project_end_financial_year}
      cepos.sort_by(&:financial_year)
      # if this is a db query we lose inputted data when there are errors
      # and we send the user back to fix it
    end

    def total_for(value)
      current_coastal_erosion_protection_outcomes.reduce(0) { |sum, cepo| sum + (cepo.send(value) || 0) }
    end

    def total_protected_households
      coastal_erosion_protection_outcomes.map(&:households_at_reduced_risk).compact.sum
    end
  end
end
