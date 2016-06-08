# frozen_string_literal: true
module PafsCore
  class UrgencyDetailsStep < BasicStep
    delegate :urgency_reason,
             :urgency_details, :urgency_details=,
             to: :project

    validates :urgency_details, presence: true

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :funding_calculator
        true
      else
        false
      end
    end

    def previous_step
      :urgency
    end

    def step
      @step ||= :urgency_details
    end

    # overridden to show this step as part of the 'urgency' step
    def is_current_step?(a_step)
      a_step.to_sym == :urgency
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:urgency_details_step).permit(:urgency_details)
    end
  end
end
