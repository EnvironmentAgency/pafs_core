# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class StartConstructionDateStep < BasicStep
    delegate :start_construction_month, :start_construction_month=,
             :start_construction_year, :start_construction_year=,
             :award_contract_month, :award_contract_year,
             to: :project

    validate :date_is_present_and_correct

    private

    def step_params(params)
      ActionController::Parameters
        .new(params)
        .require(:start_construction_date_step)
        .permit(:start_construction_month, :start_construction_year)
    end

    def date_is_present_and_correct
      date_is_present_and_in_range
      return if errors.any?

      award_contract_after_start_outline_business_case
    end

    def award_contract_after_start_outline_business_case
      dt1 = Date.new(award_contract_year, award_contract_month, 1)
      dt2 = Date.new(start_construction_year, start_construction_month, 1)

      if dt1 > dt2
        errors.add(
          :start_construction,
          "^You expect to award the project's main contract on #{dt1.month} #{dt1.year}. \
          The date you expect to start the work must come after this date."
        )
      end
    end

    def date_is_present_and_in_range
      m = "start_construction_month"
      y = "start_construction_year"
      mv = send(m)
      yv = send(y)
      unless mv.present? &&
             yv.present? &&
             (1..12).cover?(mv.to_i) &&
             (2000..2100).cover?(yv.to_i)
        errors.add(
          :start_construction,
          "^Enter the date you expect to start the work "
        )
      end
    end
  end
end
