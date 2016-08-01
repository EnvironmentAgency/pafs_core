# frozen_string_literal: true
module PafsCore
  class UrgencyStep < BasicStep
    delegate :urgency_reason, :urgency_reason=,
             to: :project

    validate :urgency_reason_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if not_urgent?
                  :funding_calculator
                else
                  :urgency_details
                end
        true
      else
        false
      end
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false unless valid?

      if urgent?
        sub_step = PafsCore::UrgencyDetailsStep.new(project)
        sub_step.completed?
      else
        true
      end
    end

    def previous_step
      :remove_fish_barrier
    end

    def step
      @step ||= :urgency
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:urgency_step).permit(:urgency_reason)
    end

    def urgency_reason_is_present_and_correct
      if urgency_reason.blank? || !PafsCore::URGENCY_REASONS.include?(urgency_reason)
        errors.add(
          :urgency_reason,
          "^If your project is urgent, select a reason. If it isn't urgent, select the first option."
        )
      end
    end

    def urgent?
      !not_urgent?
    end

    def not_urgent?
      urgency_reason == "not_urgent"
    end
  end
end
