# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class FinancialYearStep < BasicStep
    delegate :project_end_financial_year, :project_end_financial_year=, to: :project

    validates :project_end_financial_year, presence: true
    validates :project_end_financial_year, numericality: { only_integer: true }
    validates :project_end_financial_year, numericality: { greater_than: 2015,
                                                           message: "must be later than 2015" }
    validates :project_end_financial_year, numericality: { less_than: 2100,
                                                           message: "must be earlier than 2100" }

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
      :project_type
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
