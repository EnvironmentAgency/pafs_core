# frozen_string_literal: true
module PafsCore
  class ImproveRiverStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      valid? && project.save
    end

    def step
      @step ||= :improve_river
    end

    # override BasicStep#completed?
    def completed?
      return false if improve_river.nil?
      return true unless improve_river?
      PafsCore::ImproveRiverAmountStep.new(project).completed?
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_river_step).
        permit(:improve_river)
    end

    def a_choice_has_been_made
      errors.add(:improve_river,
                 "^Tell us if the project protects or improves a length of river "\
                 "or priority river habitat") if improve_river.nil?
    end
  end
end
