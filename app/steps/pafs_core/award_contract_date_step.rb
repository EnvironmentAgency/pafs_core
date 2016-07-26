# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class AwardContractDateStep < BasicStep
    delegate :award_contract_month, :award_contract_month=,
             :award_contract_year, :award_contract_year=,
             :start_outline_business_case_month, :start_outline_business_case_year,
             to: :project

    validate :date_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :start_construction_date
        true
      else
        false
      end
    end

    def previous_step
      :start_outline_business_case_date
    end

    def step
      @step ||= :award_contract_date
    end

    def is_current_step?(a_step)
      a_step.to_sym == :key_dates
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:award_contract_date_step).permit(
        :award_contract_month, :award_contract_year)
    end

    def date_is_present_and_correct
      date_is_present_and_in_range
      return if errors.any?
      award_contract_after_start_outline_business_case
    end

    def award_contract_after_start_outline_business_case
      dt1 = Date.new(start_outline_business_case_year, start_outline_business_case_month, 1)
      dt2 = Date.new(award_contract_year, award_contract_month, 1)

      errors.add(
        :award_contract,
        "^You expect to submit your outline business case for approval on #{dt1.month} #{dt1.year}. \
        The date you expect to award the project's main contract must come after this."
      ) if dt1 > dt2
    end

    def date_is_present_and_in_range
      m = "award_contract_month"
      y = "award_contract_year"
      mv = send(m)
      yv = send(y)
      errors.add(
        :award_contract,
        "^Enter the date you expect to award the project's main contract"
      ) unless mv.present? &&
               yv.present? &&
               (1..12).cover?(mv.to_i) &&
               (2000..2100).cover?(yv.to_i)
    end
  end
end
