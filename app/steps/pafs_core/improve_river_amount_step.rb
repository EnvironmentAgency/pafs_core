# frozen_string_literal: true
module PafsCore
  class ImproveRiverAmountStep < BasicStep
    delegate :improve_river_amount,
             :improve_river_amount=,
             to: :project

    validate :amount_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :habitat_creation
        true
      else
        false
      end
    end

    def previous_step
      :surface_and_groundwater
    end

    def step
      @step ||= :improve_river_amount
    end

    # overridden to show this step as part of the 'improve_spa_or_sac' step
    def is_current_step?(a_step)
      a_step.to_sym == :improve_spa_or_sac
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_river_amount_step).
        permit(:improve_river_amount)
    end

    def amount_is_present_and_correct
      if improve_river_amount.blank?
        errors.add(:improve_river_amount,
                   "^Enter a value to show how many kilometres of river "\
                   "the project will protect or improve.")
      elsif improve_river_amount <= 0
        errors.add(:improve_river_amount,
                   "^Enter a value greater than zero to show how many kilometres "\
                   "of river the project will protect or improve.")
      end
    end
  end
end
