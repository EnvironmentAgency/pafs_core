# frozen_string_literal: true

require 'roo'

module PafsCore
  module Mapper
    class PartnershipFundingCalculator
      include PafsCore::FundingCalculatorVersion

      attr_accessor :calculator_file

      CALCULATOR_MAPS = {
        v8: PafsCore::Mapper::FundingCalculatorMaps::V8,
        v9: PafsCore::Mapper::FundingCalculatorMaps::V9,
      }

      def self.default_attributes
        {
          pv_appraisal_approach: nil,
          pv_design_and_construction_costs: nil,
          pv_funding_from_other_ea_functions_sources_secured_to_date: nil,
          pv_local_levy_secured_to_date: nil,
          pv_post_construction_costs: nil,
          pv_private_contributions_secured_to_date: nil,
          pv_public_contributions_secured_to_date: nil,
          pv_whole_life_benefits: nil,
          qualifying_benefits_outcome_measures: {
            om2: {
              before: {
                most_deprived_20: {
                  moderate_risk: nil,
                  significant_risk: nil,
                  very_significant_risk: nil,
                },
                most_deprived_21_40: {
                  moderate_risk: nil,
                  significant_risk: nil,
                  very_significant_risk: nil,
                },
                least_deprived_60: {
                  moderate_risk: nil,
                  significant_risk: nil,
                  very_significant_risk: nil,
                }
              },
              after: {
                most_deprived_20: {
                  moderate_risk: nil,
                  significant_risk: nil,
                  very_significant_risk: nil,
                },
                most_deprived_21_40: {
                  moderate_risk: nil,
                  significant_risk: nil,
                  very_significant_risk: nil,
                },
                least_deprived_60: {
                  moderate_risk: nil,
                  significant_risk: nil,
                  very_significant_risk: nil,
                }
              }
            },
            om3: {
              before_construction: {
                most_deprived_20: {
                  long_term_loss: nil,
                  medium_term_loss: nil,
                },
                most_deprived_21_40: {
                  long_term_loss: nil,
                  medium_term_loss: nil,
                },
                least_deprived_60: {
                  long_term_loss: nil,
                  medium_term_loss: nil,
                },
              }
            },
            om4: {
              hectares_of_net_water_dependent_habitat_created: nil,
              hectares_of_net_water_intertidal_habitat_created: nil,
              kilometres_of_protected_river_improved: nil,
            }
          }
        }
      end

      def initialize(calculator_file:)
        self.calculator_file = calculator_file
      end

      def calculator_sheet_name
        @calculator_sheet_name ||= calculator.sheets.grep(/PF Calculator/i).first || raise("No calculator sheet found")
      end

      def sheet
        @sheet ||= calculator.sheet(calculator_sheet_name)
      end

      def calculator
        @calculator ||= Roo::Spreadsheet.open(calculator_file.path, extension: :xlsx)
      end

      def calculator_map
        @calculator_map ||= CALCULATOR_MAPS[calculator_version].new(sheet)
      end

      def attributes
        return {} unless calculator_map

        @attributes ||= calculator_map.extract_data
      end
    end
  end
end
