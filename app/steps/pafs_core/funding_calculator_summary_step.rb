# frozen_string_literal: true
module PafsCore
  class FundingCalculatorSummaryStep < BasicStep

    delegate :funding_calculator_file_name,
             :funding_calculator_updated_at,
             to: :project

    def update(params)
      true
    end
  end
end
