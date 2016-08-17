# frozen_string_literal: true
module PafsCore
  class ImproveRiverAmountStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :amount_is_present_and_correct

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_river_amount_step).
        permit(:improve_river_amount)
    end

    def amount_is_present_and_correct
      if improve_river_amount.blank?
        errors.add(:improve_river_amount,
                   "^Enter a value to show how many kilometres of river or "\
                   "priority river habitat the project will protect or improve.")
      elsif improve_river_amount <= 0
        errors.add(:improve_river_amount,
                   "^Enter a value greater than zero to show how many kilometres "\
                   "of river or priority river habitat the project will protect "\
                   "or improve.")
      end
    end
  end
end
