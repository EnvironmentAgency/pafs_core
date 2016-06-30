# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class FloodProtectionOutcomesSummaryStep < BasicStep

    delegate :flood_protection_outcomes,
             :flood_protection_outcomes=,
             :flooding?,
             :coastal_erosion?,
             :project_end_financial_year,
             to: :project

    def update(params)
      # just progress to next step
      @step = if coastal_erosion?
                :coastal_erosion_protection_outcomes
              else
                :standard_of_protection
              end
      true
    end

    def previous_step
      :flood_protection_outcomes
    end

    def step
      @step ||= :flood_protection_outcomes_summary
    end

    def disabled?
      !(flooding? && !project_end_financial_year.nil?)
    end

    def completed?
      !!(flooding? && !current_flood_protection_outcomes.empty?)
    end

    def current_flood_protection_outcomes
      fpos = flood_protection_outcomes.select { |fpo| fpo.financial_year <= project_end_financial_year}
      fpos.sort_by(&:financial_year)
      # if this is a db query we lose inputted data when there are errors
      # and we send the user back to fix it
    end

    def total_for(value)
      current_flood_protection_outcomes.reduce(0) { |sum, fpo| sum + (fpo.send(value) || 0) }
    end
  end
end
