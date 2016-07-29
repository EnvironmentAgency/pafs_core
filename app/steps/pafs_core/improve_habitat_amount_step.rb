# frozen_string_literal: true
module PafsCore
  class ImproveHabitatAmountStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :amount_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      valid? && project.save
    end

    def step
      @step ||= :improve_habitat_amount
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
