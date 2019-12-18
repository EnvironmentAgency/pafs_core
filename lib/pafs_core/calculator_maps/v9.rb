module PafsCore
  module CalculatorMaps
    class V9 < Base
      def data
        @data ||= {
          strategic_approach: binary_value(sheet.cell("E", 17)),
          raw_partnership_funding_score: sheet.cell("E", 19),
          adjusted_partnership_funding_score: sheet.cell("K", 19),
          pv_whole_life_costs: sheet.cell("E", 33),
          pv_whole_life_benefits: sheet.cell("E", 37),
          duration_of_benefits: sheet.cell("E", 38),
          hectares_of_net_water_dependent_habitat_created: 0,
          hectares_of_net_water_intertidal_habitat_created: 0,
          kilometres_of_protected_river_improved: 0
        }
      end
    end
  end
end
