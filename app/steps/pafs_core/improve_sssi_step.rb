# frozen_string_literal: true
module PafsCore
  class ImproveSssiStep < BasicStep
    delegate :improve_sssi,
      :improve_sssi=,
      :improve_sssi?,
      to: :project

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if improve_sssi?
                  :improve_habitat_amount
                else
                  :improve_hpi
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
      @step ||= :improve_sssi
    end

    # overridden to show this step as part of the 'improve_spa_or_sac' step
    def is_current_step?(a_step)
      a_step.to_sym == :improve_spa_or_sac
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false if improve_sssi.nil?

      if improve_sssi?
        PafsCore::ImproveHabitatAmountStep.new(project).completed?
      else
        PafsCore::ImproveHpiStep.new(project).completed?
      end
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_sssi_step).
        permit(:improve_sssi)
    end

    def a_choice_has_been_made
      errors.add(:improve_sssi,
                 "^Tell us if the project protects or improves a Site of Special "\
                 "Scientific Interest") if improve_sssi.nil?
    end
  end
end
