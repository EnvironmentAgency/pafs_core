# frozen_string_literal: true
module PafsCore
  module Risks
    delegate :fluvial_flooding?,
            :tidal_flooding?,
            :groundwater_flooding?,
            :surface_water_flooding?,
            :coastal_erosion?,
            to: :project

    def selected_risks
      r = []
      r << :fluvial_flooding if fluvial_flooding?
      r << :tidal_flooding if tidal_flooding?
      r << :groundwater_flooding if groundwater_flooding?
      r << :surface_water_flooding if surface_water_flooding?
      r << :coastal_erosion if coastal_erosion?
      r
    end

    def protects_against_flooding?
      fluvial_flooding? || tidal_flooding? || groundwater_flooding? || surface_water_flooding?
    end

    def protects_against_coastal_erosion?
      coastal_erosion?
    end
  end
end
