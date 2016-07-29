# frozen_string_literal: true
module PafsCore
  class ImproveHpiStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      valid? && project.save
    end

    def step
      @step ||= :improve_hpi
    end

    # override BasicStep#completed?
    def completed?
      return false if improve_hpi.nil?
      return true unless improve_hpi?
      PafsCore::ImproveHabitatAmountStep.new(project).completed?
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_hpi_step).
        permit(:improve_hpi)
    end

    def a_choice_has_been_made
      errors.add(:improve_hpi,
                 "^Tell us if the project protects or improves a Habitat of "\
                 "Principal Importance") if improve_hpi.nil?
    end
  end
end
