# frozen_string_literal: true

module PafsCore
  class HabitatCreationAmountStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :amount_is_present_and_correct

    private

    def step_params(params)
      params
                                  .require(:habitat_creation_amount_step)
                                  .permit(:create_habitat_amount)
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
