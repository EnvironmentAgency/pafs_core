module PafsCore
  module Mapper
    class PartnershipFundingCalculator
      attr_accessor :calculator_file
      attr_accessor :attributes

      attr_accessor :sheet

      def initialize(calculator_file:)
        self.calculator_file = calculator_file
        self.attributes = {}

        calculator = Roo::Spreadsheet.open(calculator_file.path, extension: :xlsx)
        self.sheet = calculator.sheet("PF Calculator")

        extract_data(calculator)
      end

      def extract_data(calculator)
        @attributes = {
          pv_appraisal_approach:                                      sheet.cell('H', 32),
          pv_design_and_construction_costs:                           sheet.cell('H', 33),
          pv_post_construction_costs:                                 sheet.cell('H', 36),
          pv_local_levy_secured_to_date:                              sheet.cell('H', 40),
          pv_public_contributions_secured_to_date:                    sheet.cell('H', 41),
          pv_private_contributions_secured_to_date:                   sheet.cell('H', 42),
          pv_funding_from_other_ea_functions_sources_secured_to_date: sheet.cell('H', 43),
          pv_whole_life_benefits: sheet.cell('H', 29),
          qualifying_benefits_outcome_measures: {
            om2: {
              before: {
                most_deprived_20: {
                  moderate_risk:          sheet.cell('E', 52),
                  significant_risk:       sheet.cell('F', 52),
                  very_significant_risk:  sheet.cell('G', 52)
                },
                most_deprived_21_40: {
                  moderate_risk:          sheet.cell('E', 53),
                  significant_risk:       sheet.cell('F', 53),
                  very_significant_risk:  sheet.cell('G', 53)
                },
                least_deprived_60: {
                  moderate_risk:          sheet.cell('E', 54),
                  significant_risk:       sheet.cell('F', 54),
                  very_significant_risk:  sheet.cell('G', 54)
                }
              },
              after: {
                most_deprived_20: {
                  moderate_risk:          sheet.cell('I', 52),
                  significant_risk:       sheet.cell('J', 52),
                  very_significant_risk:  sheet.cell('K', 52)
                },
                most_deprived_21_40: {
                  moderate_risk:          sheet.cell('I', 53),
                  significant_risk:       sheet.cell('J', 53),
                  very_significant_risk:  sheet.cell('K', 53)
                },
                least_deprived_60: {
                  moderate_risk:          sheet.cell('I', 54),
                  significant_risk:       sheet.cell('J', 54),
                  very_significant_risk:  sheet.cell('K', 54)
                }
              }
            },
            om3: {
              before_construction: {
                most_deprived_20: {
                  long_time_loss:         sheet.cell('F', 68),
                  medium_term_loss:       sheet.cell('G', 68),
                },
                most_deprived_21_40: {
                  long_time_loss:         sheet.cell('F', 69),
                  medium_term_loss:       sheet.cell('G', 68),
                },
                least_deprived_60: {
                  long_time_loss:         sheet.cell('F', 70),
                  medium_term_loss:       sheet.cell('G', 68),
                },
              }
            },
            om4: {
              hectares_of_net_water_dependent_habitat_created:  sheet.cell('C', 81),
              hectares_of_net_water_intertidal_habitat_created: sheet.cell('C', 82),
              kilometres_of_protected_river_improved:           sheet.cell('C', 83),
            }
          }
        }
      end
    end
  end
end
