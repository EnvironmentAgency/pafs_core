# frozen_string_literal: true

module PafsCore
  module Mapper
    module FundingCalculatorMaps
      class V9 < Base
        VERSION_NAME = "v1 2020"

        def extract_data
          {
            partnership_funding_calculator_version: VERSION_NAME,
            date_of_pf_calculator: sheet.cell("D", 9),
            lead_rma: sheet.cell("D", 10),
            project_stage: sheet.cell("M", 7),
            option_reference: sheet.cell("M", 8),

            pv_appraisal_approach: sheet.cell("E", 28),
            pv_design_and_construction_costs: sheet.cell("E", 29),
            pv_risk_contingency: sheet.cell("E", 30),
            pv_future_costs: sheet.cell("E", 32),
            pv_whole_life_benefits: sheet.cell("E", 39),

            pv_local_levy_towards_appraisal_costs: sheet.cell("K", 28),
            pv_local_levy_towards_qualifying_outcomes_upfront: sheet.cell("M", 28),
            pv_local_levy_towards_qualifying_outcomes_future: sheet.cell("O", 28),

            pv_public_contributions_towards_appraisal_costs: sheet.cell("K", 29),
            pv_public_contributions_towards_qualifying_outcomes_upfront: sheet.cell("M", 29),
            pv_public_contributions_towards_qualifying_outcomes_future: sheet.cell("O", 29),
            pv_public_contributions_contributor_or_fund: sheet.cell("Q", 29),

            pv_private_contributions_towards_appraisal_costs: sheet.cell("K", 30),
            pv_private_contributions_towards_qualifying_outcomes_upfront: sheet.cell("M", 30),
            pv_private_contributions_towards_qualifying_outcomes_future: sheet.cell("O", 30),
            pv_private_contributions_contributor_or_fund: sheet.cell("Q", 30),

            pv_funding_from_other_ea_functions_sources_towards_appraisal_costs: sheet.cell("K", 31),
            pv_funding_from_other_ea_functions_sources_towards_qualifying_outcomes_upfront: sheet.cell("M", 31),
            pv_funding_from_other_ea_functions_sources_towards_qualifying_outcomes_future: sheet.cell("O", 31),
            pv_funding_from_other_ea_functions_sources_contributor_or_fund: sheet.cell("Q", 31),

            pv_whole_life_benefits_appraisal_period: sheet.cell("E", 37),
            pv_whole_life_benefits_duration_of_benefits: sheet.cell("E", 38),
            pv_whole_life_benefits_people_related_impacts: sheet.cell("E", 41),

            economic_summary_sheet_completed: sheet.cell("K", 37),
            economic_data_included_in_business_case: sheet.cell("K", 38),
            # wider_benefits_data_included_in_business_case: sheet.cell('K', 39),

            year_measures_ready_for_service: sheet.cell("E", 58),

            qualifying_benefits_outcome_measures: {
              om2_present_day: {
                before: {
                  most_deprived_20: {
                    moderate_risk: sheet.cell("G", 46),
                    intermediate_risk: sheet.cell("H", 46),
                    significant_risk: sheet.cell("I", 46),
                    very_significant_risk: sheet.cell("J", 46)
                  },
                  most_deprived_21_40: {
                    moderate_risk: sheet.cell("G", 47),
                    intermediate_risk: sheet.cell("H", 47),
                    significant_risk: sheet.cell("I", 47),
                    very_significant_risk: sheet.cell("J", 47)
                  },
                  least_deprived_60: {
                    moderate_risk: sheet.cell("G", 48),
                    intermediate_risk: sheet.cell("H", 48),
                    significant_risk: sheet.cell("I", 48),
                    very_significant_risk: sheet.cell("J", 48)
                  }
                },
                after: {
                  most_deprived_20: {
                    low_risk: sheet.cell("F", 51),
                    moderate_risk: sheet.cell("G", 51),
                    intermediate_risk: sheet.cell("H", 51),
                    significant_risk: sheet.cell("I", 51),
                    very_significant_risk: sheet.cell("J", 51)
                  },
                  most_deprived_21_40: {
                    low_risk: sheet.cell("F", 52),
                    moderate_risk: sheet.cell("G", 52),
                    intermediate_risk: sheet.cell("H", 52),
                    significant_risk: sheet.cell("I", 52),
                    very_significant_risk: sheet.cell("J", 52)
                  },
                  least_deprived_60: {
                    low_risk: sheet.cell("F", 53),
                    moderate_risk: sheet.cell("G", 53),
                    intermediate_risk: sheet.cell("H", 53),
                    significant_risk: sheet.cell("I", 53),
                    very_significant_risk: sheet.cell("J", 53)
                  }
                }
              },
              om2_in_2040: {
                before: {
                  most_deprived_20: {
                    moderate_risk: sheet.cell("G", 61),
                    intermediate_risk: sheet.cell("H", 61),
                    significant_risk: sheet.cell("I", 61),
                    very_significant_risk: sheet.cell("J", 61)
                  },
                  most_deprived_21_40: {
                    moderate_risk: sheet.cell("G", 62),
                    intermediate_risk: sheet.cell("H", 62),
                    significant_risk: sheet.cell("I", 62),
                    very_significant_risk: sheet.cell("J", 62)
                  },
                  least_deprived_60: {
                    moderate_risk: sheet.cell("G", 63),
                    intermediate_risk: sheet.cell("H", 63),
                    significant_risk: sheet.cell("I", 63),
                    very_significant_risk: sheet.cell("J", 63)
                  }
                },
                after: {
                  most_deprived_20: {
                    low_risk: sheet.cell("F", 66),
                    moderate_risk: sheet.cell("G", 66),
                    intermediate_risk: sheet.cell("H", 66),
                    significant_risk: sheet.cell("I", 66),
                    very_significant_risk: sheet.cell("J", 66)
                  },
                  most_deprived_21_40: {
                    low_risk: sheet.cell("F", 67),
                    moderate_risk: sheet.cell("G", 67),
                    intermediate_risk: sheet.cell("H", 67),
                    significant_risk: sheet.cell("I", 67),
                    very_significant_risk: sheet.cell("J", 67)
                  },
                  least_deprived_60: {
                    low_risk: sheet.cell("F", 68),
                    moderate_risk: sheet.cell("G", 68),
                    intermediate_risk: sheet.cell("H", 68),
                    significant_risk: sheet.cell("I", 68),
                    very_significant_risk: sheet.cell("J", 68)
                  }
                }
              },
              om3: {
                before_construction: {
                  most_deprived_20: {
                    long_term_loss: sheet.cell("F", 74),
                    medium_term_loss: sheet.cell("G", 74)
                  },
                  most_deprived_21_40: {
                    long_term_loss: sheet.cell("F", 75),
                    medium_term_loss: sheet.cell("G", 75)
                  },
                  least_deprived_60: {
                    long_term_loss: sheet.cell("F", 76),
                    medium_term_loss: sheet.cell("G", 76)
                  }
                }
              },
              om4: {
                net_change_hectares: {
                  before: {
                    intertidal_habitat: {
                      poor: sheet.cell("D", 83),
                      moderate: sheet.cell("E", 83),
                      good: sheet.cell("F", 83)
                    },
                    woodland: {
                      poor: sheet.cell("D", 84),
                      moderate: sheet.cell("E", 84),
                      good: sheet.cell("F", 84)
                    },
                    wet_woodland: {
                      poor: sheet.cell("D", 85),
                      moderate: sheet.cell("E", 85),
                      good: sheet.cell("F", 85)
                    },
                    wetlands_wet_grassland: {
                      poor: sheet.cell("D", 86),
                      moderate: sheet.cell("E", 86),
                      good: sheet.cell("F", 86)
                    },
                    grassland: {
                      poor: sheet.cell("D", 87),
                      moderate: sheet.cell("E", 87),
                      good: sheet.cell("F", 87)
                    },
                    moor_heath: {
                      poor: sheet.cell("D", 88),
                      moderate: sheet.cell("E", 88),
                      good: sheet.cell("F", 88)
                    },
                    ponds_lakes: {
                      poor: sheet.cell("D", 89),
                      moderate: sheet.cell("E", 89),
                      good: sheet.cell("F", 89)
                    },
                    arable_land: {
                      poor: sheet.cell("D", 90),
                      moderate: sheet.cell("E", 90),
                      good: sheet.cell("F", 90)
                    }
                  },

                  after: {
                    intertidal_habitat: {
                      poor: sheet.cell("H", 83),
                      moderate: sheet.cell("I", 83),
                      good: sheet.cell("J", 83)
                    },
                    woodland: {
                      poor: sheet.cell("H", 84),
                      moderate: sheet.cell("I", 84),
                      good: sheet.cell("J", 84)
                    },
                    wet_woodland: {
                      poor: sheet.cell("H", 85),
                      moderate: sheet.cell("I", 85),
                      good: sheet.cell("J", 85)
                    },
                    wetlands_wet_grassland: {
                      poor: sheet.cell("H", 86),
                      moderate: sheet.cell("I", 86),
                      good: sheet.cell("J", 86)
                    },
                    grassland: {
                      poor: sheet.cell("H", 87),
                      moderate: sheet.cell("I", 87),
                      good: sheet.cell("J", 87)
                    },
                    moor_heath: {
                      poor: sheet.cell("H", 88),
                      moderate: sheet.cell("I", 88),
                      good: sheet.cell("J", 88)
                    },
                    ponds_lakes: {
                      poor: sheet.cell("H", 89),
                      moderate: sheet.cell("I", 89),
                      good: sheet.cell("J", 89)
                    },
                    arable_land: {
                      poor: sheet.cell("H", 90),
                      moderate: sheet.cell("I", 90),
                      good: sheet.cell("J", 90)
                    }
                  }
                },
                length_of_habitat_enhanced: {
                  comprehensive_restoration_of_physical_modifications: sheet.cell("P", 84),
                  partial_restoration_of_physical_modifications: sheet.cell("P", 85),
                  single_major_physical_improvement: sheet.cell("P", 86)
                }
              }
            }
          }
        end
      end
    end
  end
end
