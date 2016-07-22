# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ReadyForServiceDateStep < BasicStep
    delegate :ready_for_service_month, :ready_for_service_month=,
             :ready_for_service_year, :ready_for_service_year=,
             :start_construction_month, :start_construction_year,
             to: :project

    validate :date_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :funding_sources
        true
      else
        false
      end
    end

    def previous_step
      :start_construction_date
    end

    def step
      @step ||= :ready_for_service_date
    end

    def is_current_step?(a_step)
      a_step.to_sym == :key_dates
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:ready_for_service_date_step).permit(
        :ready_for_service_month, :ready_for_service_year)
    end

    def date_is_present_and_correct
      date_is_present_and_in_range
      return if errors.any?
      ready_for_service_after_start_construction
    end

    def ready_for_service_after_start_construction
      dt1 = Date.new(start_construction_year, start_construction_month, 1)
      dt2 = Date.new(ready_for_service_year, ready_for_service_month, 1)

      errors.add(:ready_for_service, "can't be earlier than award of contract date") if dt1 > dt2
    end

    def date_is_present_and_in_range
      m = "ready_for_service_month"
      y = "ready_for_service_year"
      mv = send(m)
      yv = send(y)
      errors.add(:ready_for_service, "^Enter a valid date") unless mv.present? &&
                                                                   yv.present? &&
                                                                   (1..12).cover?(mv.to_i) &&
                                                                   (2000..2100).cover?(yv.to_i)
    end
  end
end
