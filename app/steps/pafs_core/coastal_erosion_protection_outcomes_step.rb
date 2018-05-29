# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class CoastalErosionProtectionOutcomesStep < BasicStep
    include PafsCore::Risks, PafsCore::Outcomes, PafsCore::FinancialYear
    delegate :project_type,
             :project_protects_households?,
             :reduced_risk_of_households_for_coastal_erosion,
             :reduced_risk_of_households_for_coastal_erosion=,
             to: :project

    validate :at_least_one_value, :values_make_sense, :sensible_number_of_houses

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
        "In the applicable year(s), tell us how many households are at a reduced risk of coastal erosion (column A), OR if this does not apply select the checkbox."
      ) if coastal_total_protected_households.zero? and !project.reduced_risk_of_households_for_coastal_erosion?
    end

    private
    def sensible_number_of_houses
      limit = 1000000
      a_insensible = []
      b_insensible = []
      c_insensible = []
      coastal_erosion_protection_outcomes.each do |cepo|
        a = cepo.households_at_reduced_risk.to_i
        b = cepo.households_protected_from_loss_in_next_20_years.to_i
        c = cepo.households_protected_from_loss_in_20_percent_most_deprived.to_i

        a_insensible.push cepo.id if a > limit
        b_insensible.push cepo.id if b > limit
        c_insensible.push cepo.id if c > limit
      end

      errors.add(
        :base,
        "The number of households at reduced risk must be less than or equal to 1 million."
      ) if !a_insensible.empty?

      errors.add(
        :base,
        "The number of households protected from loss in the next 20 years must be less than or equal to 1 million."
      ) if !b_insensible.empty?

      errors.add(
        :base,
        "The number of households protected from loss in the 20 percent most deprived areas must \
        be less than or equal to 1 million."
      ) if !c_insensible.empty?
    end

    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:coastal_erosion_protection_outcomes_step)
                                  .permit(:reduced_risk_of_households_for_coastal_erosion, coastal_erosion_protection_outcomes_attributes:
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
