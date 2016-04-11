# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class EarliestDateStep < BasicStep
    delegate :could_start_early?,
             :earliest_start_month, :earliest_start_month=,
             :earliest_start_year, :earliest_start_year=,
             to: :project

    validate :earliest_start_date_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :location
        true
      else
        false
      end
    end

    def previous_step
      :earliest_start
    end

    def step
      @step ||= :earliest_date
    end

    # overridden to show this step as part of the 'earliest start' step
    def is_current_step?(a_step)
      a_step.to_sym == :earliest_start
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:earliest_date_step).permit(
        :earliest_start_month, :earliest_start_year)
    end

    def earliest_start_date_is_present_and_correct
      validate_month
      validate_year
    end

    def validate_month
      m = earliest_start_month
      if m.blank?
        errors.add(:earliest_start_month, "cannot be blank")
      else
        mon = m.to_i
        if mon < 1 || mon > 12 || (m.to_s != mon.to_s)
          errors.add(:earliest_start_month, "must be in the range 1-12")
        end
      end
    end

    def validate_year
      y = earliest_start_year
      if y.blank?
        errors.add(:earliest_start_year, "cannot be blank")
      else
        year = y.to_i
        if (year < 2000 || year > 2099) || (year.to_s != y.to_s)
          errors.add(:earliest_start_year, "must be in the range 2000-2099")
        end
      end
    end
  end
end
