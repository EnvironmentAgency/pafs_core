# frozen_string_literal: true

module PafsCore
  class ImproveHabitatAmountStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :amount_is_present_and_correct

    private

    def step_params(params)
      params
                                  .require(:improve_habitat_amount_step)
                                  .permit(:improve_habitat_amount)
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
