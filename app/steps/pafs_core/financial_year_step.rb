# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class FinancialYearStep < BasicStep
    delegate :project_end_financial_year, :project_end_financial_year=, to: :project

    validates :project_end_financial_year, presence: true

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :project_timescales
        true
      else
        false
      end
    end

    def previous_step
      :project_reference_number
    end

    def step
      @step ||= :financial_year
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:financial_year_step).permit(:project_end_financial_year)
    end
  end
end
