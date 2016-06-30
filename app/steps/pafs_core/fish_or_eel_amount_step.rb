# frozen_string_literal: true
module PafsCore
  class FishOrEelAmountStep < BasicStep
    delegate :fish_or_eel_amount,
             :fish_or_eel_amount=,
             to: :project

    validate :amount_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :urgency
        true
      else
        false
      end
    end

    def previous_step
      :habitat_creation
    end

    def step
      @step ||= :fish_or_eel_amount
    end

    # overridden to show this step as part of the 'surface_and_groundwater' step
    def is_current_step?(a_step)
      a_step.to_sym == :remove_fish_barrier
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:fish_or_eel_amount_step).
        permit(:fish_or_eel_amount)
    end

    def amount_is_present_and_correct
      if fish_or_eel_amount.blank?
        errors.add(:fish_or_eel_amount,
                   "^Enter a value to show how many kilometres of river "\
                   "the project is likely to open for fish or eel passage.")
      elsif fish_or_eel_amount <= 0
        errors.add(:fish_or_eel_amount,
                   "^Enter a value greater than zero to show how many kilometres "\
                   "of river the project is likely to open for fish or eel passage.")
      end
    end
  end
end
