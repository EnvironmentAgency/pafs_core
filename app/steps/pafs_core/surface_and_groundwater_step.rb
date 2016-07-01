# frozen_string_literal: true
module PafsCore
  class SurfaceAndGroundwaterStep < BasicStep
    delegate :improve_surface_or_groundwater,
      :improve_surface_or_groundwater=,
      :improve_surface_or_groundwater?,
      to: :project

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if improve_surface_or_groundwater?
                  :surface_and_groundwater_amount
                else
                  :improve_spa_or_sac
                end
        true
      else
        false
      end
    end

    def previous_step
      :approach
    end

    def step
      @step ||= :surface_and_groundwater
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false if improve_surface_or_groundwater.nil?
      # if 'No' selected then no sub-step needed
      return true if !improve_surface_or_groundwater?

      PafsCore::SurfaceAndGroundwaterAmountStep.new(project).completed?
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:surface_and_groundwater_step).
        permit(:improve_surface_or_groundwater)
    end

    def a_choice_has_been_made
      errors.add(:improve_surface_or_groundwater,
                 "^Tell us if the project protects or improves "\
                 "surface water or groundwater") if improve_surface_or_groundwater.nil?
    end
  end
end
