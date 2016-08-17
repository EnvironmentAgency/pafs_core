# frozen_string_literal: true
module PafsCore
  class RisksStep < BasicStep
    include PafsCore::Risks
    delegate :project_protects_households?,
             to: :project

    validate :at_least_one_risk_is_selected

    def update(params)
      assign_attributes(step_params(params))
      if valid?
        self.main_risk = selected_risks.first.to_s if selected_risks.count == 1
        project.save
      else
        false
      end
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
        selected_risks.count > 0
    end
  end
end
