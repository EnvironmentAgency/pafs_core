# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class CoastalErosionProtectionOutcomesStep < BasicStep
    include PafsCore::Risks, PafsCore::Outcomes, PafsCore::FinancialYear
    delegate :project_type,
             :project_protects_households?,
             to: :project
    validate :at_least_one_value, :values_make_sense

    def before_view(params)
      setup_coastal_erosion_protection_outcomes
    end

    private
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

    def at_least_one_value
      errors.add(
        :base,
        "In the applicable year(s), tell us how many households are at a reduced risk of coastal erosion (column A)."
      ) if total_protected_households.zero?
    end

    def total_protected_households
      coastal_erosion_protection_outcomes.map(&:households_at_reduced_risk).compact.sum
    end

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
      years.concat((current_financial_year..project_end_financial_year).to_a)
      years.each { |y| build_missing_year(y) }
    end

    def build_missing_year(year)
      if !coastal_erosion_protection_outcomes.exists?(financial_year: year)
        coastal_erosion_protection_outcomes.build(financial_year: year)
      end
    end
  end
end
