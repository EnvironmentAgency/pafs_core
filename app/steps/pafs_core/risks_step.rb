# frozen_string_literal: true
module PafsCore
  class RisksStep < BasicStep
    include PafsCore::Risks
    delegate :fluvial_flooding, :fluvial_flooding=,
             :tidal_flooding, :tidal_flooding=,
             :groundwater_flooding, :groundwater_flooding=,
             :surface_water_flooding, :surface_water_flooding=,
             :sea_flooding, :sea_flooding=,
             :coastal_erosion, :coastal_erosion=,
             :project_protects_households?,
             to: :project

    validate :at_least_one_risk_is_selected

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if selected_risks.count > 1
                  :main_risk
                else
                  project.update_attributes(main_risk: selected_risks.first.to_s)
                  if protects_against_flooding?
                    :flood_protection_outcomes
                  else
                    :coastal_erosion_protection_outcomes
                  end
                end
        true
      else
        false
      end
    end

    def previous_step
      # TODO: this should be :map but it isn't there yet
      :earliest_start
    end

    def step
      @step ||= :risks
    end

    def disabled?
      !project_protects_households?
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:risks_step).permit(
        :fluvial_flooding,
        :tidal_flooding,
        :groundwater_flooding,
        :surface_water_flooding,
        :sea_flooding,
        :coastal_erosion)
    end

    def at_least_one_risk_is_selected
      errors.add(:base, "Select the risks your project protects against") unless
        [fluvial_flooding,
         tidal_flooding,
         groundwater_flooding,
         surface_water_flooding,
         sea_flooding,
         coastal_erosion].any?(&:present?)
    end
  end
end
