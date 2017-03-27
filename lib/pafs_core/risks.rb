# frozen_string_literal: true
module PafsCore
  module Risks
    RISKS = [
      :fluvial_flooding,
      :tidal_flooding,
      :groundwater_flooding,
      :surface_water_flooding,
      :sea_flooding,
      :coastal_erosion
    ].freeze

    RISKS.each do |r|
      delegate r, "#{r}=", "#{r}?", to: :project
    end
    delegate :main_risk, :main_risk=, to: :project

    def selected_risks
      RISKS.select { |r| send("#{r}?") }
    end

    def risks_started?
      selected_risks.count > 0
    end

    def protects_against_multiple_risks?
      selected_risks.count > 1
    end

    def protects_against_flooding?
      fluvial_flooding? || tidal_flooding? || groundwater_flooding? || surface_water_flooding? || sea_flooding?
    end

    def protects_against_coastal_erosion?
      coastal_erosion?
    end

    def risk_from_string(str)
      I18n.t("pafs_core.fcerm1.risks").invert[str]
    end
  end
end
