# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class CoastalErosionProtectionOutcomesStep < BasicStep
    include PafsCore::FinancialYear
    include PafsCore::Outcomes
    include PafsCore::Risks
    delegate :project_type,
             :project_protects_households?,
             :reduced_risk_of_households_for_coastal_erosion?,
             :reduced_risk_of_households_for_coastal_erosion,
             :reduced_risk_of_households_for_coastal_erosion=,
             to: :project

    validate :at_least_one_value, :values_make_sense, :sensible_number_of_houses

    validate :has_values, if: :reduced_risk_of_households_for_coastal_erosion?

    def before_view(_params)
      setup_coastal_erosion_protection_outcomes
    end

    private

    def has_values
      coastal_erosion_protection_outcomes.each do |outcome|
        %i[households_at_reduced_risk households_protected_from_loss_in_next_20_years households_protected_from_loss_in_20_percent_most_deprived].each do |attr|
          if outcome.send(attr).to_i > 0
            return errors.add(
              :base,
              "In the applicable year(s), tell us how many households moved to a lower flood risk category (column A), OR if this does not apply select the checkbox."
            )
          end
        end
      end
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
      unless b_too_big.empty?
        errors.add(
          :base,
          "The number of households protected from loss within the next 20 years (column B) must be lower \
          than or equal to the number of households at a reduced risk of coastal erosion (column A)."
        )
      end

      unless c_too_big.empty?
        errors.add(
          :base,
          "The number of households in the 20% most deprived areas (column C) must be lower than or \
          equal to the number of households protected from loss within the next 20 years (column B)."
        )
      end
    end

    def at_least_one_value
      if coastal_total_protected_households.zero? && !project.reduced_risk_of_households_for_coastal_erosion?
        errors.add(
          :base,
          "In the applicable year(s), tell us how many households are at a reduced risk of coastal erosion (column A), OR if this does not apply select the checkbox."
        )
      end
    end

    def sensible_number_of_houses
      limit = 1_000_000
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

      unless a_insensible.empty?
        errors.add(
          :base,
          "The number of households at reduced risk must be less than or equal to 1 million."
        )
      end

      unless b_insensible.empty?
        errors.add(
          :base,
          "The number of households protected from loss in the next 20 years must be less than or equal to 1 million."
        )
      end

      unless c_insensible.empty?
        errors.add(
          :base,
          "The number of households protected from loss in the 20 percent most deprived areas must \
          be less than or equal to 1 million."
        )
      end
    end

    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:coastal_erosion_protection_outcomes_step)
                                  .permit(:reduced_risk_of_households_for_coastal_erosion, coastal_erosion_protection_outcomes_attributes:
                                    %i[
                                      id
                                      financial_year
                                      households_at_reduced_risk
                                      households_protected_from_loss_in_next_20_years
                                      households_protected_from_loss_in_20_percent_most_deprived
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
      unless coastal_erosion_protection_outcomes.exists?(financial_year: year)
        coastal_erosion_protection_outcomes.build(financial_year: year)
      end
    end
  end
end
