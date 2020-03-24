# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  module StandardOfProtection
    STANDARD_OF_PROTECTION_FLOODING = %i[
      very_significant
      significant
      moderate
      low
    ].freeze

    STANDARD_OF_PROTECTION_COASTAL_BEFORE = %i[
      less_than_one_year
      one_to_four_years
      five_to_nine_years
      ten_years_or_more
    ].freeze

    STANDARD_OF_PROTECTION_COASTAL_AFTER = %i[
      less_than_ten_years
      ten_to_nineteen_years
      twenty_to_fortynine_years
      fifty_years_or_more
    ].freeze

    %i[flood_protection_before
       flood_protection_after
       coastal_protection_before
       coastal_protection_after].each do |a|
      delegate a, "#{a}=", to: :project
    end

    # flood protection levels are stored as integers that correlate to
    # the category of risk of flooding
    # 0 - Very significant
    # 1 - Significant
    # 2 - Moderate
    # 3 - Low
    def flood_risk_options
      STANDARD_OF_PROTECTION_FLOODING
    end

    def flood_risk_symbol(n)
      STANDARD_OF_PROTECTION_FLOODING[n]
    end

    # coastal erosion protection levels are stored as integers that correlate to
    # the category of risk, before the project
    # 0 - Less than 1 year
    # 1 - 1 to 4 years
    # 2 - 5 to 9 years
    # 3 - 10 years or more
    def coastal_erosion_before_options
      STANDARD_OF_PROTECTION_COASTAL_BEFORE
    end

    def coastal_risk_before_symbol(n)
      STANDARD_OF_PROTECTION_COASTAL_BEFORE[n]
    end

    # coastal erosion protection levels are stored as integers that correlate to
    # the category of risk, after the project
    # 0 - Less than 10 years
    # 1 - 10 to 19 years
    # 2 - 20 to 49 years
    # 3 - 50 years or more
    def coastal_erosion_after_options
      STANDARD_OF_PROTECTION_COASTAL_AFTER
    end

    def coastal_risk_after_symbol(n)
      STANDARD_OF_PROTECTION_COASTAL_AFTER[n]
    end

    def standard_of_protection_label(t)
      I18n.t(t, scope: "pafs_core.standard_of_protection")
    end

    # validation for flood protection
    def flood_protection_should_be_same_or_better_for(attr)
      if flood_protection_before.present? && flood_protection_after.present? &&
         flood_protection_before > flood_protection_after
        errors.add(attr, "^Once the project is complete, the flood risk "\
                   "must not be greater than it is now")
      end
    end

    # validation for coastal erosion protection
    def coastal_erosion_protection_should_be_same_or_better_for(attr)
      if coastal_protection_before.present? &&
         coastal_protection_after.present? &&
         coastal_erosion_before_options[coastal_protection_before] == :ten_years_or_more &&
         coastal_erosion_after_options[coastal_protection_after] == :less_than_ten_years
        errors.add(attr, "^Once the project is complete, the length of time before"\
                   " coastal erosion affects the area must not be less than it"\
                   " is now")
      end
    end

    def sop_from_string(value)
      I18n.t("pafs_core.fcerm1.standard_of_protection").invert[value]
    end
  end
end
