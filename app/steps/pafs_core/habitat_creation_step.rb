# frozen_string_literal: true
module PafsCore
  class HabitatCreationStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      valid? && project.save
    end

    def step
      @step ||= :habitat_creation
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false if create_habitat.nil?
      return true unless create_habitat?
      PafsCore::HabitatCreationAmountStep.new(project).completed?
    end

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
