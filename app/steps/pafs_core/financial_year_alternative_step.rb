# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class FinancialYearAlternativeStep < BasicStep
    delegate :project_end_financial_year, :project_end_financial_year=, to: :project

    validate :project_end_financial_year_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :key_dates
        true
      else
        false
      end
    end

    def previous_step
      :financial_year
    end

    def step
      @step ||= :financial_year_alternative
    end

    def is_current_step?(a_step)
      a_step.to_sym == :financial_year
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:financial_year_alternative_step)
                                  .permit(:project_end_financial_year)
    end

    def current_financial_year
      Time.current.uk_financial_year
    end

    def project_end_financial_year_is_present_and_correct
      v = project_end_financial_year
      if v.blank?
        errors.add(:project_end_financial_year, "can't be blank")
      elsif v.to_s =~ /\A\d{4}\z/
        n = v.to_i
        if n < current_financial_year
          errors.add(:project_end_financial_year, "must be #{current_financial_year} or later")
        elsif n > 2100
          errors.add(:project_end_financial_year, "must be 2100 or earlier")
        end
      else
        errors.add(:project_end_financial_year, "must be a number in the range 2000 to 2100")
      end
    end
  end
end
