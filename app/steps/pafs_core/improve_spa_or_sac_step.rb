# frozen_string_literal: true
module PafsCore
  class ImproveSpaOrSacStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_spa_or_sac_step).
        permit(:improve_spa_or_sac)
    end

    def a_choice_has_been_made
      errors.add(:improve_spa_or_sac,
                 "^Tell us if the project protects or improves a Special "\
                 "Protected Area or Special Area of Conservation") if improve_spa_or_sac.nil?
    end
  end
end
