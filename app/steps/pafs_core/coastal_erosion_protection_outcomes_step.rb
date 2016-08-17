# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class CoastalErosionProtectionOutcomesStep < BasicStep
    delegate :project_end_financial_year,
             :coastal_erosion_protection_outcomes,
             :coastal_erosion_protection_outcomes=,
             :coastal_erosion_protection_outcomes_attributes=,
             :coastal_erosion?,
             :flooding?,
             :project_type,
             :project_protects_households?,
             to: :project
    validate :at_least_one_value, :values_make_sense

    def update(params)
      # if javascript is not enabled then we need to show the totals
      # as the next page after successfully saving
      js_enabled = !!params.fetch(:js_enabled, false)
      result = false

      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if js_enabled
                  :standard_of_protection
                else
                  :coastal_erosion_protection_outcomes_summary
                end
        true
      else
        false
      end
    end

    def previous_step
      if flooding?
        :flood_protection_outcomes
      else
        :risks
      end
    end

    def step
      @step ||= :coastal_erosion_protection_outcomes
    end

    def disabled?
      !(coastal_erosion? && !project_end_financial_year.nil? && project_protects_households?)
    end

    def completed?
      !!(coastal_erosion? && !total_protected_households.zero?)
    end

    def current_coastal_erosion_protection_outcomes
      cepos = coastal_erosion_protection_outcomes.select { |cepo| cepo.financial_year <= project_end_financial_year}
      cepos.sort_by(&:financial_year)
      # if this is a db query we lose inputted data when there are errors
      # and we send the user back to fix it
    end

    def before_view
      setup_coastal_erosion_protection_outcomes
    end

    def values_make_sense
      b_too_big = []
      c_too_big = []
      coastal_erosion_protection_outcomes.each do |cepo|
        a = cepo.households_at_reduced_risk.to_i
        b = cepo.households_protected_from_loss_in_next_20_years.to_i
        c = cepo.households_protected_from_loss_in_20_percent_most_deprived.to_i

        b_too_big.push cepo.id if a < b
        c_too_big.push cepo.id if b < c
      end
      errors.add(
        :base,
        "The number of households protected from loss within the next 20 years (column B) must be lower \
        than or equal to the number of households at a reduced risk of coastal erosion (column A)."
      ) if !b_too_big.empty?

      errors.add(
        :base,
        "The number of households in the 20% most deprived areas (column C) must be lower than or \
        equal to the number of households protected from loss within the next 20 years (column B)."
      ) if !c_too_big.empty?
    end

    def total_protected_households
      coastal_erosion_protection_outcomes.map(&:households_at_reduced_risk).compact.sum
    end

    def at_least_one_value
      errors.add(
        :base,
        "In the applicable year(s), tell us how many households are at a reduced risk of coastal erosion (column A)."
      ) if total_protected_households.zero?
    end

    private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:coastal_erosion_protection_outcomes_step)
                                  .permit(coastal_erosion_protection_outcomes_attributes:
                                    [
                                      :id,
                                      :financial_year,
                                      :households_at_reduced_risk,
                                      :households_protected_from_loss_in_next_20_years,
                                      :households_protected_from_loss_in_20_percent_most_deprived
                                    ])
    end

    def setup_coastal_erosion_protection_outcomes
      # need to ensure the project has the right number of funding_values entries
      # for the tables
      # we need at least:
      #   previous years
      #   current financial year to :project_end_financial_year
      years = [-1]
      years.concat((2015..project_end_financial_year).to_a)
      years.each { |y| build_missing_year(y) }
    end

    def build_missing_year(year)
      if !coastal_erosion_protection_outcomes.exists?(financial_year: year)
        coastal_erosion_protection_outcomes.build(financial_year: year)
      end
    end
  end
end
