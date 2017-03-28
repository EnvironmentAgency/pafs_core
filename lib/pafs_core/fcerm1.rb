# frozen_string_literal: true

module PafsCore
  module Fcerm1
    FIRST_DATA_ROW = 7

    FCERM1_COLUMN_MAP = [
      { column: "A",  field_name: :reference_number },
      { column: "B",  field_name: :name },
      { column: "C",  field_name: :lrma_project_reference, export: false, import: false },
      { column: "D",  field_name: :ldw_cpw_idb_number, export: false, import: false },
      { column: "E",  field_name: :region, import: false },
      { column: "F",  field_name: :rfcc, import: false },
      { column: "G",  field_name: :ea_area, import: false },
      { column: "H",  field_name: :rma_name },
      { column: "I",  field_name: :rma_type, import: false },
      { column: "J",  field_name: :coastal_group, import: false },
      { column: "K",  field_name: :project_type },
      { column: "L",  field_name: :main_risk },
      { column: "M",  field_name: :moderation_code },
      { column: "N",  field_name: :package_reference, export: false, import: false },
      { column: "O",  field_name: :consented },
      { column: "P",  field_name: :grid_reference },
      { column: "Q",  field_name: :project_location, export: false, import: false },
      { column: "R",  field_name: :county, import: false },
      { column: "S",  field_name: :parliamentary_constituency, import: false },
      { column: "T",  field_name: :parliamentary_benefit_area, export: false, import: false },
      { column: "U",  field_name: :agreed_strategy, export: false, import: false },
      { column: "V",  field_name: :approach },
      { column: "W",  field_name: :environmental_considerations, export: false, import: false },

      { column: "X",
        field_name: :flood_protection_before,
        if: ->(p) { p.project_protects_households? } },

      { column: "Y",
        field_name: :flood_protection_after,
        if: ->(p) { p.project_protects_households? } },

      { column: "Z",
        field_name: :coastal_protection_before,
        if: ->(p) { p.project_protects_households? } },

      { column: "AA",
        field_name: :coastal_protection_after,
        if: ->(p) { p.project_protects_households? } },

      { column: "AB", field_name: :new_builds, export: false, import: false },

      { column: "AC", field_name: :strategic_approach, import: false },
      { column: "AD", field_name: :raw_partnership_funding_score, import: false },
      { column: "AE", field_name: :adjusted_partnership_funding_score, import: false },
      { column: "AF", field_name: :pv_whole_life_costs, import: false },
      { column: "AG", field_name: :pv_whole_life_benefits, import: false },
      { column: "AH", field_name: :benefit_cost_ratio, import: false },
      { column: "AI", field_name: :duration_of_benefits, import: false },

      { column: "AJ", field_name: :public_contributors },
      { column: "AK", field_name: :private_contributors },
      { column: "AL", field_name: :other_ea_contributors },
      { column: "AM", field_name: :scheme_comments, export: false, import: false },

      { column: "AN", field_name: :earliest_start_date },
      { column: "AO", field_name: :start_business_case_date },
      { column: "AP", field_name: :award_contract_date },
      { column: "AQ", field_name: :start_construction_date },
      { column: "AR", field_name: :ready_for_service_date },

      # Project totals AS - BJ (formula)
      { column: "AS", field_name: :project_totals, export: false, import: false },

      # Total Project expenditure BK - BX (formula)
      { column: "BK", field_name: :project_totals, export: false, import: false },

      # GiA columns BY - CL
      { column: "BY", field_name: :fcerm_gia, date_range: true },

      # Growth columns CM - CZ
      { column: "CM", field_name: :growth_funding, date_range: true },

      # Local levy columns DA - DN
      { column: "DA", field_name: :local_levy, date_range: true },

      # Internal drainage board columns DO - EB
      { column: "DO", field_name: :internal_drainage_boards, date_range: true },

      # Public contribution columns EC - EP
      { column: "EC", field_name: :public_contributions, date_range: true },

      # Private contribution columns EQ - FD
      { column: "EQ", field_name: :private_contributions, date_range: true },

      # Other EA contribution columns FE - FR
      { column: "FE", field_name: :other_ea_contributions, date_range: true },

      # Not yet identified contribution columns FS - GF
      { column: "FS", field_name: :not_yet_identified, date_range: true },

      # Households affected by flooding OM2 GG - GT
      { column: "GG",
        field_name: :households_at_reduced_risk,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding OM2b GU - HH
      { column: "GU",
        field_name: :moved_from_very_significant_and_significant_to_moderate_or_low,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Households affected by flooding OM2c HI - HV
      { column: "HI",
        field_name: :households_protected_from_loss_in_20_percent_most_deprived,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes OM3 HW - IJ
      { column: "HW",
        field_name: :coastal_households_at_reduced_risk,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes OM3b IK - IX
      { column: "IK",
        field_name: :coastal_households_protected_from_loss_in_next_20_years,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # Coastal erosion protection outcomes OM3c IY - JL
      { column: "IY",
        field_name: :coastal_households_protected_from_loss_in_20_percent_most_deprived,
        date_range: true,
        if: ->(p) { p.project_protects_households? } },

      # From PF calculator
      { column: "JM", field_name: :hectares_of_net_water_dependent_habitat_created, import: false },
      { column: "JN", field_name: :hectares_of_net_water_intertidal_habitat_created, import: false },
      { column: "JO", field_name: :kilometres_of_protected_river_improved, import: false },

      # Natural flood risk management measure
      { column: "JP", field_name: :natural_measures, export: false, import: false },
      { column: "JQ", field_name: :main_natural_measure, export: false, import: false },
      { column: "JR", field_name: :natural_measures_costs, export: false, import: false },

      # # spa/sac, sssi or none
      { column: "JS", field_name: :designated_site },
      { column: "JT", field_name: :improve_surface_or_groundwater_amount },
      { column: "JU", field_name: :remove_fish_or_eel_barrier },
      { column: "JV", field_name: :fish_or_eel_amount },
      { column: "JW", field_name: :improve_river_amount },
      { column: "JX", field_name: :improve_habitat_amount },
      { column: "JY", field_name: :create_habitat_amount }
    ].freeze

    A2Z = ("A".."Z").to_a.freeze

    # convert spreadsheet column "code" (eg. A, GF, ZZ) to column index
    def column_index(column_code)
      if column_code.length == 1
        A2Z.index(column_code)
      else
        n = A2Z.index(column_code[0])
        m = A2Z.index(column_code[1])
        26 + (n * 26) + m
      end
    end
  end
end
