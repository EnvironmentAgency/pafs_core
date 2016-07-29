# frozen_string_literal: true
module PafsCore
  class UrgencyStep < BasicStep
    include PafsCore::Urgency

    validate :urgency_reason_is_present_and_correct

    # override BasicStep#completed? to handle earliest_date step
    # def completed?
    #   return false unless valid?
    #
    #   if urgent?
    #     sub_step = PafsCore::UrgencyDetailsStep.new(project)
    #     sub_step.completed?
    #   else
    #     true
    #   end
    # end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:urgency_step).permit(:urgency_reason)
    end

    def urgency_reason_is_present_and_correct
      if urgency_reason.blank? || !URGENCY_REASONS.include?(urgency_reason)
        errors.add(:urgency_reason, "^Please select the reason for the urgency")
      end
    end
  end
end
