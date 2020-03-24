# frozen_string_literal: true

module PafsCore
  class FloodProtectionOutcomesStep < BasicStep
    include PafsCore::FinancialYear
    include PafsCore::Risks
    include PafsCore::Outcomes
    delegate :project_end_financial_year,
             :project_type,
             :project_protects_households?,
             :reduced_risk_of_households_for_floods?,
             :reduced_risk_of_households_for_floods,
             :reduced_risk_of_households_for_floods=,
             to: :project

    validate :at_least_one_value, :values_make_sense, :sensible_number_of_houses

    validate :has_values, if: :reduced_risk_of_households_for_floods?

    def before_view(_params)
      setup_flood_protection_outcomes
    end

    private

    def has_values
      values = flood_protection_outcomes.collect do |outcome|
        if outcome.households_at_reduced_risk.present? || outcome.moved_from_very_significant_and_significant_to_moderate_or_low.present? || outcome.households_protected_from_loss_in_20_percent_most_deprived.present?
          true
        end
      end.compact!

      if values.present? && values.include?(true)
        errors.add(
          :base,
          "In the applicable year(s), tell us how many households moved to a lower flood risk category (column A), OR if this does not apply select the checkbox."
        )
      end
    end

    def values_make_sense
      b_too_big = []
      c_too_big = []
      flood_protection_outcomes.each do |fpo|
        a = fpo.households_at_reduced_risk.to_i
        b = fpo.moved_from_very_significant_and_significant_to_moderate_or_low.to_i
        c = fpo.households_protected_from_loss_in_20_percent_most_deprived.to_i

        b_too_big.push fpo.id if a < b
        c_too_big.push fpo.id if b < c
      end
      unless b_too_big.empty?
        errors.add(
          :base,
          "The number of households moved from very significant or significant to\
          the moderate or low flood risk category (column B) must be lower than or equal\
          to the number of households moved to a lower flood risk category (column A)."
        )
      end

      unless c_too_big.empty?
        errors.add(
          :base,
          "The number of households in the 20% most deprived areas (column C) must be lower than or equal \
          to the number of households moved from very significant \
          or significant to the moderate or low flood risk category (column B)."
        )
      end
    end

    def at_least_one_value
      if flooding_total_protected_households.zero? && !project.reduced_risk_of_households_for_floods?
        errors.add(
          :base,
          "In the applicable year(s), tell us how many households moved to a lower flood risk category (column A), OR if this does not apply select the checkbox."
        )
      end
    end

    def sensible_number_of_houses
      limit = 1_000_000
      a_insensible = []
      b_insensible = []
      c_insensible = []
      flood_protection_outcomes.each do |fpo|
        a = fpo.households_at_reduced_risk.to_i
        b = fpo.moved_from_very_significant_and_significant_to_moderate_or_low.to_i
        c = fpo.households_protected_from_loss_in_20_percent_most_deprived.to_i

        a_insensible.push fpo.id if a > limit
        b_insensible.push fpo.id if b > limit
        c_insensible.push fpo.id if c > limit
      end

      unless a_insensible.empty?
        errors.add(
          :base,
          "The number of households at reduced risk must be less than or equal to 1 million."
        )
      end

      unless b_insensible.empty?
        errors.add(
          :base,
          "The number of households moved from very significant and significant to moderate or low must be \
          less than or equal to 1 million."
        )
      end

      unless c_insensible.empty?
        errors.add(
          :base,
          "The number of households protected from loss in the 20 percent most deprived must be \
          less than or equal to 1 million."
        )
      end
    end

    def step_params(params)
      params
                                  .require(:flood_protection_outcomes_step)
                                  .permit(:reduced_risk_of_households_for_floods, flood_protection_outcomes_attributes:
                                    %i[
                                      id
                                      financial_year
                                      households_at_reduced_risk
                                      moved_from_very_significant_and_significant_to_moderate_or_low
                                      households_protected_from_loss_in_20_percent_most_deprived
                                    ])
    end

    def setup_flood_protection_outcomes
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
      unless flood_protection_outcomes.exists?(financial_year: year)
        flood_protection_outcomes.build(financial_year: year)
      end
    end
  end
end
