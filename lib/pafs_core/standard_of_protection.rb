# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  module StandardOfProtection
    STANDARD_OF_PROTECTION_FLOODING = [
      :very_significant,
      :significant,
      :moderate,
      :low
    ].freeze

    STANDARD_OF_PROTECTION_COASTAL_BEFORE = [
      :less_than_one_year,
      :one_to_four_years,
      :five_to_nine_years,
      :ten_years_or_more
    ].freeze

    STANDARD_OF_PROTECTION_COASTAL_AFTER = [
      :less_than_ten_years,
      :ten_to_nineteen_years,
      :twenty_to_fortynine_years,
      :fifty_years_or_more
    ].freeze

    [:flood_protection_before,
     :flood_protection_after,
     :coastal_protection_before,
     :coastal_protection_after].each do |a|
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

    # coastal erosion protection levels are stored as integers that correlate to
    # the category of risk, before the project
    # 0 - Less than 1 year
    # 1 - 1 to 4 years
    # 2 - 5 to 9 years
    # 3 - 10 years or more
    def coastal_erosion_before_options
      STANDARD_OF_PROTECTION_COASTAL_BEFORE
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

    def standard_of_protection_label(t)
      I18n.t(t, scope: "pafs_core.standard_of_protection")
    end
  end
end
