# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class StartOutlineBusinessCaseDateStep < BasicStep
    delegate :start_outline_business_case_month, :start_outline_business_case_month=,
             :start_outline_business_case_year, :start_outline_business_case_year=,
             to: :project

    validate :date_is_present_and_in_range

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :award_contract_date
        true
      else
        false
      end
    end

    def previous_step
      :financial_year
    end

    def step
      @step ||= :start_outline_business_case_date
    end

    def is_current_step?(a_step)
      a_step.to_sym == :key_dates
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:start_outline_business_case_date_step).permit(
        :start_outline_business_case_month, :start_outline_business_case_year)
    end

    def date_is_present_and_in_range
      m = "start_outline_business_case_month"
      y = "start_outline_business_case_year"
      mv = send(m)
      yv = send(y)
      errors.add(:start_outline_business_case, "^Enter a valid date") unless  mv.present? &&
                                                                              yv.present? &&
                                                                              (1..12).cover?(mv.to_i) &&
                                                                              (2000..2100).cover?(yv.to_i)
    end
  end
end
