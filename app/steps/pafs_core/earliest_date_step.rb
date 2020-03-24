# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class EarliestDateStep < BasicStep
    delegate :could_start_early?,
             :earliest_start_month, :earliest_start_month=,
             :earliest_start_year, :earliest_start_year=,
             to: :project

    validate :earliest_start_date_is_present_and_correct

    private

    def step_params(params)
      ActionController::Parameters.new(params).require(:earliest_date_step).permit(
        :earliest_start_month, :earliest_start_year
      )
    end

    def earliest_start_date_is_present_and_correct
      if earliest_start_month.blank? || earliest_start_year.blank?
        errors.add(:earliest_start, "^Tell us the earliest date the project can start")
      else
        validate_month
        validate_year
      end
    end

    def validate_month
      m = earliest_start_month
      if m.present?
        mon = m.to_i
        if mon < 1 || mon > 12 || (m.to_s != mon.to_s)
          errors.add(:earliest_start, "^The month must be between 1 and 12")
        end
      end
    end

    def validate_year
      y = earliest_start_year
      if y.present?
        year = y.to_i
        if (year < 2000 || year > 2100) || (year.to_s != y.to_s)
          errors.add(:earliest_start, "^The year must be between 2000 and 2100")
        end
      end
    end
  end
end
