# frozen_string_literal: true
module PafsCore
  class HabitatCreationAmountStep < BasicStep
    delegate :create_habitat_amount,
             :create_habitat_amount=,
             to: :project

    validate :amount_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :remove_fish_barrier
        true
      else
        false
      end
    end

    def previous_step
      :improve_spa_or_sac
    end

    def step
      @step ||= :habitat_creation_amount
    end

    # overridden to show this step as part of the 'habitat_creation' step
    def is_current_step?(a_step)
      a_step.to_sym == :habitat_creation
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:habitat_creation_amount_step).
        permit(:create_habitat_amount)
    end

    def amount_is_present_and_correct
      if create_habitat_amount.blank?
        errors.add(:create_habitat_amount,
                   "^Enter a value to show how many hectares of habitat "\
                   "the project is likely to create.")
      elsif create_habitat_amount <= 0
        errors.add(:create_habitat_amount,
                   "^Enter a value greater than zero to show how many hectares "\
                   "the project is likely to create.")
      end
    end
  end
end
