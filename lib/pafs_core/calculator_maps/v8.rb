module PafsCore
  module CalculatorMaps
    class V8 < Base
      def data
        @data ||= {
          strategic_approach: binary_value(sheet.cell("J", 25)),
          raw_partnership_funding_score: sheet.cell("H", 15),
          adjusted_partnership_funding_score: sheet.cell("H", 19),
          pv_whole_life_costs: sheet.cell("H", 37),
          pv_whole_life_benefits: sheet.cell("H", 29),
          duration_of_benefits: sheet.cell("H", 27),
          hectares_of_net_water_dependent_habitat_created: sheet.cell("C", 81),
          hectares_of_net_water_intertidal_habitat_created: sheet.cell("C", 82),
          kilometres_of_protected_river_improved: sheet.cell("C", 83)
        }
      end
    end
  end
end

