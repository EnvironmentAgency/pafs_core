# frozen_string_literal: true
module PafsCore
  class FundingValuesSummaryStep < BasicStep
    include PafsCore::FundingSources
    delegate :project_end_financial_year,
             :funding_values,
             to: :project

    def update(params)
      # do nothing
      true
    end
  end
end
