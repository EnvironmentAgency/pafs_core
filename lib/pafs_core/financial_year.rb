# frozen_string_literal: true
module PafsCore
  module FinancialYear
    delegate :project_end_financial_year,
             :project_end_financial_year=,
             to: :project

    def current_financial_year
      Time.current.uk_financial_year
    end

    def financial_year_options
      current_financial_year..current_financial_year + 5
    end

    def project_end_financial_year_is_present_and_correct
      v = project_end_financial_year
      if v.blank? || v.zero? || v.nil?
        errors.add(
          :project_end_financial_year,
          "^Tell us the financial year when the project will stop spending funds."
        )
      elsif v < current_financial_year
        errors.add(:project_end_financial_year, "^The financial year must be in the future")
      elsif v > 2100
        errors.add(:project_end_financial_year, "must be 2100 or earlier")
      end
    end
  end
end
