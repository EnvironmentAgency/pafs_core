# frozen_string_literal: true
module PafsCore
  class HabitatCreationStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:habitat_creation_step).
        permit(:create_habitat)
    end

    def a_choice_has_been_made
      errors.add(:create_habitat,
                 "^Tell us if the project creates habitat") if create_habitat.nil?
    end
  end
end
