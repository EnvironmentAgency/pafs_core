# frozen_string_literal: true
module PafsCore
  class SurfaceAndGroundwaterStep < BasicStep
    delegate :improve_surface_or_groundwater,
      :improve_surface_or_groundwater=,
      :improve_surface_or_groundwater?,
      to: :project

    validate :a_choice_has_been_made

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
