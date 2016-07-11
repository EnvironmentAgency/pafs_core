# frozen_string_literal: true
module PafsCore
  class FundingCalculatorSummaryStep < BasicStep

    delegate :funding_calculator_file_name,
             :funding_calculator_updated_at,
             to: :project

    def update(params)
      @step = :summary
      true
    end

    def previous_step
      :urgency
    end

    def step
      @step ||= :funding_calculator_summary
    end

    # overridden to show this step as part of the 'funding_calculator' step
    def is_current_step?(a_step)
      a_step.to_sym == :funding_calculator
    end
  end
end
