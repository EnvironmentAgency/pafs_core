# frozen_string_literal: true

module PafsCore
  class FinancialYearAlternativeStep < BasicStep
    include PafsCore::FinancialYear

    validate :project_end_financial_year_is_present_and_correct

    private

    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:financial_year_alternative_step)
                                  .permit(:project_end_financial_year)
    end
  end
end
