# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class RisksStep < BasicStep
    delegate :fluvial_flooding, :fluvial_flooding=,
             :tidal_flooding, :tidal_flooding=,
             :groundwater_flooding, :groundwater_flooding=,
             :surface_water_flooding, :surface_water_flooding=,
             :coastal_erosion, :coastal_erosion=,
             to: :project

    validate :at_least_one_risk_is_selected

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :main_risk
        true
      else
        false
      end
    end

    def previous_step
      :map
    end

    def step
      @step ||= :risks
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:risks_step).permit(
        :fluvial_flooding,
        :tidal_flooding,
        :groundwater_flooding,
        :surface_water_flooding,
        :coastal_erosion)
    end

    def at_least_one_risk_is_selected
      errors.add(:base, "You must select at least one risk") unless
        [fluvial_flooding,
         tidal_flooding,
         groundwater_flooding,
         surface_water_flooding,
         coastal_erosion].any?(&:present?)
    end
  end
end
