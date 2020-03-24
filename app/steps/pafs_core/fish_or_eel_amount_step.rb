# frozen_string_literal: true

module PafsCore
  class FishOrEelAmountStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :amount_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:fish_or_eel_amount_step)
        .permit(:fish_or_eel_amount)
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
