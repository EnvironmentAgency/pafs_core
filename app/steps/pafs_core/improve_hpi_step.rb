# frozen_string_literal: true
module PafsCore
  class ImproveHpiStep < BasicStep
    delegate :improve_hpi,
      :improve_hpi=,
      :improve_hpi?,
      to: :project

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if improve_hpi?
                  :improve_habitat_amount
                else
                  :improve_river
                end
        true
      else
        false
      end
    end

    def previous_step
      :surface_and_groundwater
    end

    def step
      @step ||= :improve_hpi
    end

    # overridden to show this step as part of the 'improve_spa_or_sac' step
    def is_current_step?(a_step)
      a_step.to_sym == :improve_spa_or_sac
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false if improve_hpi.nil?
      if improve_hpi?
        PafsCore::ImproveHabitatAmountStep.new(project).completed?
      else
        PafsCore::ImproveRiverStep.new(project).completed?
      end
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
