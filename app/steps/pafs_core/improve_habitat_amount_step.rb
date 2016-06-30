# frozen_string_literal: true
module PafsCore
  class ImproveHabitatAmountStep < BasicStep
    delegate :improve_habitat_amount,
             :improve_habitat_amount=,
             to: :project

    validate :amount_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :improve_river
        true
      else
        false
      end
    end

    def previous_step
      :surface_and_groundwater
    end

    def step
      @step ||= :improve_habitat_amount
    end

    # overridden to show this step as part of the 'surface_and_groundwater' step
    def is_current_step?(a_step)
      a_step.to_sym == :improve_spa_or_sac
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false unless valid?
      PafsCore::ImproveRiverStep.new(project).completed?
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_habitat_amount_step).
        permit(:improve_habitat_amount)
    end

    def amount_is_present_and_correct
      if improve_habitat_amount.blank?
        errors.add(:improve_habitat_amount,
                   "^Enter a value to show how many hectares of habitat "\
                   "the project will protect or improve.")
      elsif improve_habitat_amount <= 0
        errors.add(:improve_habitat_amount,
                   "^Enter a value greater than zero to show how many hectares "\
                   "the project will protect or improve.")
      end
    end
  end
end
