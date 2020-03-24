# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class ReadyForServiceDateStep < BasicStep
    delegate :ready_for_service_month, :ready_for_service_month=,
             :ready_for_service_year, :ready_for_service_year=,
             :start_construction_month, :start_construction_year,
             to: :project

    validate :date_is_present_and_correct

    private

    def step_params(params)
      params.require(:ready_for_service_date_step).permit(
        :ready_for_service_month, :ready_for_service_year
      )
    end

    def date_is_present_and_correct
      date_is_present_and_in_range
      return if errors.any?

      ready_for_service_after_start_construction
    end

    def ready_for_service_after_start_construction
      dt1 = Date.new(start_construction_year, start_construction_month, 1)
      dt2 = Date.new(ready_for_service_year, ready_for_service_month, 1)

      if dt1 > dt2
        errors.add(
          :ready_for_service,
          "^You expect to start the work on #{dt1.month} #{dt1.year}. \
          The date you expect the project to start achieving its benefits must come after this date."
        )
      end
    end

    def date_is_present_and_in_range
      m = "ready_for_service_month"
      y = "ready_for_service_year"
      mv = send(m)
      yv = send(y)
      unless mv.present? &&
             yv.present? &&
             (1..12).cover?(mv.to_i) &&
             (2000..2100).cover?(yv.to_i)
        errors.add(
          :ready_for_service,
          "^Enter the date you expect the project to start achieving its benefits"
        )
      end
    end

  end
end
