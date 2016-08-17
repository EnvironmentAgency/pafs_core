# frozen_string_literal: true
module PafsCore
  module Risks
    RISKS = [
      :fluvial_flooding,
      :tidal_flooding,
      :groundwater_flooding,
      :surface_water_flooding,
      :coastal_erosion
    ].freeze

    RISKS.each do |r|
      delegate r, "#{r}=", "#{r}?", to: :project
    end
    delegate :main_risk, :main_risk=, to: :project

    def selected_risks
      RISKS.select { |r| send("#{r}?") }
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
  end
end
