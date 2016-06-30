# frozen_string_literal: true
module PafsCore
  class ImproveSpaOrSacStep < BasicStep
    delegate :improve_spa_or_sac,
      :improve_spa_or_sac=,
      :improve_spa_or_sac?,
      to: :project

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if improve_spa_or_sac?
                  :improve_habitat_amount
                else
                  :improve_sssi
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
      @step ||= :improve_spa_or_sac
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false if improve_spa_or_sac.nil?

      if improve_spa_or_sac?
        PafsCore::ImproveHabitatAmountStep.new(project).completed?
      else
        PafsCore::ImproveSssiStep.new(project).completed?
      end
    end

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
