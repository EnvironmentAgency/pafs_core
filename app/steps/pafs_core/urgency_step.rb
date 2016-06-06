# frozen_string_literal: true
module PafsCore
  class UrgencyStep < BasicStep
    delegate :urgency_reason, :urgency_reason=,
             # :urgent_because_statutory_need, :urgent_because_statutory_need=, :urgent_because_statutory_need?,
             # :urgent_because_legal_need, :urgent_because_legal_need=, :urgent_because_legal_need?,
             # :urgent_because_h_and_s_issue, :urgent_because_h_and_s_issue=, :urgent_because_h_and_s_issue?,
             # :urgent_because_emergency, :urgent_because_emergency=, :urgent_because_emergency?,
             # :urgent_because_time_limited, :urgent_because_time_limited=, :urgent_because_time_limited?,
             # :urgent_because_other_reason, :urgent_because_other_reason=, :urgent_because_other_reason?,
             to: :project

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if urgency_reason.present?
                  :urgency_details
                else
                  :funding_calculator
                end
        true
      else
        false
      end
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false unless urgency_reason.present?

      sub_step = PafsCore::UrgencyDetailsStep.new(project)
      sub_step.completed?
    end

    def previous_step
      :fish_eel_passages
    end

    def step
      @step ||= :urgency
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:urgency_step).permit(:urgency_reason)
    end

    def validate_urgency_reason_is_present_and_correct
      if urgency_reason.present?
        # validate reason is a permitted value
        errors.add(:urgency_reason, "^Please select the reason for the urgency") unless
          PafsCore::URGENCY_REASONS.include? urgency_reason
      else
        errors.add(:urgency_reason, "^Please select the reason for the urgency")
      end
    end
  end
end
