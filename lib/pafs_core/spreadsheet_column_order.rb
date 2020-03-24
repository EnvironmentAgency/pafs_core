# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  SPREADSHEET_BASIC_INFO = %i[
    name
    reference_number
    lrma_project_reference
    ldw_cpw_idb_number
    region
    rfcc
    ea_area
    lead_rma
    lead_rma_type
    coastal_group
    project_type
    main_risk
    urgency_reason
    packages
    grid_ref
    project_location
    county
    parliamentary_constituency
    parliamentary_constituencies_benefit_area
    agreed_strategy
    approach
    environmental_considerations
  ].freeze

  SPREADSHEET_STANDARD_OF_PROTECTION = %i[
    flood_protection_before
    flood_protection_after
    coastal_protection_before
    coastal_protection_after
    new_builds
  ].freeze

  SPREADSHEET_PF_CALCULATOR_FIGURES = %i[
    strategic_approach
    raw_partnership_funding_score
    adjusted_partnership_funding_score
    pv_whole_life_costs
    pv_whole_life_benefits
    pv_whole_life_benefit_cost_ratio
    duration_of_benefits
    scheme_comments
  ].freeze

  SPREADSHEET_WFD_INFO = %i[
    improve_sssi_spa_or_sac
    remove_fish_or_eel_barrier
    improve_surface_or_groundwater_amount
    improve_habitat_amount
    improve_river_amount
    fish_or_eel_amount
    create_habitat_amount
    additional_potential
    additional_funding_required_for_additional_benefits
  ].freeze

  SPREADSHEET_DATES = %i[
    earliest_start
    start_outline_business_case
    award_contract
    start_construction
    ready_for_service
  ].freeze

  SPREADSHEET_TOTALS = %i[
    gia_total
    levy_total
    idb_total
    public_total
    private_total
    ea_total
    growth_total
    nyi_total
    total_total
    flood_households_total
    flood_households_moved_total
    flood_most_deprived_total
    coastal_households_total
    coastal_households_protected_total
    coastal_most_deprived_total
    hectares_of_net_water_dependent_habitat_created
    hectares_of_net_water_intertidal_habitat_created
    kilometres_of_protected_river_improved
  ].freeze

  SPREADSHEET_SIX_YEAR_TOTALS = %i[
    gia_six_year_total
    contributions_six_year_total
    total_six_year_total
    households_six_year_total
  ].freeze

  SPREADSHEET_GIA_FIGURES = %i[
    gia_previous_years
    gia_2015
    gia_2016
    gia_2017
    gia_2018
    gia_2019
    gia_2020
    gia_2021
    gia_2022
    gia_2023
    gia_2024
    gia_2025
    gia_2026
    gia_2027
  ].freeze

  SPREADSHEET_LEVY_FIGURES = %i[
    levy_previous_years
    levy_2015
    levy_2016
    levy_2017
    levy_2018
    levy_2019
    levy_2020
    levy_2021
    levy_2022
    levy_2023
    levy_2024
    levy_2025
    levy_2026
    levy_2027
  ].freeze

  SPREADSHEET_IDB_FIGURES = %i[
    idb_previous_years
    idb_2015
    idb_2016
    idb_2017
    idb_2018
    idb_2019
    idb_2020
    idb_2021
    idb_2022
    idb_2023
    idb_2024
    idb_2025
    idb_2026
    idb_2027
  ].freeze

  SPREADSHEET_PUBLIC_FIGURES = %i[
    public_previous_years
    public_2015
    public_2016
    public_2017
    public_2018
    public_2019
    public_2020
    public_2021
    public_2022
    public_2023
    public_2024
    public_2025
    public_2026
    public_2027
  ].freeze

  SPREADSHEET_PRIVATE_FIGURES = %i[
    private_previous_years
    private_2015
    private_2016
    private_2017
    private_2018
    private_2019
    private_2020
    private_2021
    private_2022
    private_2023
    private_2024
    private_2025
    private_2026
    private_2027
  ].freeze

  SPREADSHEET_EA_FIGURES = %i[
    ea_previous_years
    ea_2015
    ea_2016
    ea_2017
    ea_2018
    ea_2019
    ea_2020
    ea_2021
    ea_2022
    ea_2023
    ea_2024
    ea_2025
    ea_2026
    ea_2027
  ].freeze

  SPREADSHEET_GROWTH_FIGURES = %i[
    growth_previous_years
    growth_2015
    growth_2016
    growth_2017
    growth_2018
    growth_2019
    growth_2020
    growth_2021
    growth_2022
    growth_2023
    growth_2024
    growth_2025
    growth_2026
    growth_2027
  ].freeze

  SPREADSHEET_NYI_FIGURES = %i[
    nyi_previous_years
    nyi_2015
    nyi_2016
    nyi_2017
    nyi_2018
    nyi_2019
    nyi_2020
    nyi_2021
    nyi_2022
    nyi_2023
    nyi_2024
    nyi_2025
    nyi_2026
    nyi_2027
  ].freeze

  SPREADSHEET_TOTAL_FIGURES = %i[
    total_previous_years
    total_2015
    total_2016
    total_2017
    total_2018
    total_2019
    total_2020
    total_2021
    total_2022
    total_2023
    total_2024
    total_2025
    total_2026
    total_2027
  ].freeze

  SPREADSHEET_COASTAL_FIGURES = %i[
    coastal_households_previous_years
    coastal_households_2015
    coastal_households_2016
    coastal_households_2017
    coastal_households_2018
    coastal_households_2019
    coastal_households_2020
    coastal_households_2021
    coastal_households_2022
    coastal_households_2023
    coastal_households_2024
    coastal_households_2025
    coastal_households_2026
    coastal_households_2027
    coastal_households_protected_previous_years
    coastal_households_protected_2015
    coastal_households_protected_2016
    coastal_households_protected_2017
    coastal_households_protected_2018
    coastal_households_protected_2019
    coastal_households_protected_2020
    coastal_households_protected_2021
    coastal_households_protected_2022
    coastal_households_protected_2023
    coastal_households_protected_2024
    coastal_households_protected_2025
    coastal_households_protected_2026
    coastal_households_protected_2027
    coastal_most_deprived_previous_years
    coastal_most_deprived_2015
    coastal_most_deprived_2016
    coastal_most_deprived_2017
    coastal_most_deprived_2018
    coastal_most_deprived_2019
    coastal_most_deprived_2020
    coastal_most_deprived_2021
    coastal_most_deprived_2022
    coastal_most_deprived_2023
    coastal_most_deprived_2024
    coastal_most_deprived_2025
    coastal_most_deprived_2026
    coastal_most_deprived_2027
  ].freeze

  SPREADSHEET_FUTURE_FIGURES = %i[
    gia_future_total
    total_future_total
    future_contributions_total
    future_households_total
  ].freeze

  SPREADSHEET_FLOODING_FIGURES = %i[
    flood_households_previous_years
    flood_households_2015
    flood_households_2016
    flood_households_2017
    flood_households_2018
    flood_households_2019
    flood_households_2020
    flood_households_2021
    flood_households_2022
    flood_households_2023
    flood_households_2024
    flood_households_2025
    flood_households_2026
    flood_households_2027
    flood_households_moved_previous_years
    flood_households_moved_2015
    flood_households_moved_2016
    flood_households_moved_2017
    flood_households_moved_2018
    flood_households_moved_2019
    flood_households_moved_2020
    flood_households_moved_2021
    flood_households_moved_2022
    flood_households_moved_2023
    flood_households_moved_2024
    flood_households_moved_2025
    flood_households_moved_2026
    flood_households_moved_2027
    flood_most_deprived_previous_years
    flood_most_deprived_2015
    flood_most_deprived_2016
    flood_most_deprived_2017
    flood_most_deprived_2018
    flood_most_deprived_2019
    flood_most_deprived_2020
    flood_most_deprived_2021
    flood_most_deprived_2022
    flood_most_deprived_2023
    flood_most_deprived_2024
    flood_most_deprived_2025
    flood_most_deprived_2026
    flood_most_deprived_2027
  ].freeze

  SPREADSHEET_OM4_COLUMNS = %i[
    hectares_of_net_water_dependent_habitat_created_previous_years
    hectares_of_net_water_dependent_habitat_created_2015
    hectares_of_net_water_dependent_habitat_created_2016
    hectares_of_net_water_dependent_habitat_created_2017
    hectares_of_net_water_dependent_habitat_created_2018
    hectares_of_net_water_dependent_habitat_created_2019
    hectares_of_net_water_dependent_habitat_created_2020
    hectares_of_net_water_dependent_habitat_created_2021
    hectares_of_net_water_dependent_habitat_created_2022
    hectares_of_net_water_dependent_habitat_created_2023
    hectares_of_net_water_dependent_habitat_created_2024
    hectares_of_net_water_dependent_habitat_created_2025
    hectares_of_net_water_dependent_habitat_created_2026
    hectares_of_net_water_dependent_habitat_created_2027
    hectares_of_net_water_intertidal_habitat_created_previous_years
    hectares_of_net_water_intertidal_habitat_created_2015
    hectares_of_net_water_intertidal_habitat_created_2016
    hectares_of_net_water_intertidal_habitat_created_2017
    hectares_of_net_water_intertidal_habitat_created_2018
    hectares_of_net_water_intertidal_habitat_created_2019
    hectares_of_net_water_intertidal_habitat_created_2020
    hectares_of_net_water_intertidal_habitat_created_2021
    hectares_of_net_water_intertidal_habitat_created_2022
    hectares_of_net_water_intertidal_habitat_created_2023
    hectares_of_net_water_intertidal_habitat_created_2024
    hectares_of_net_water_intertidal_habitat_created_2025
    hectares_of_net_water_intertidal_habitat_created_2026
    hectares_of_net_water_intertidal_habitat_created_2027
    kilometres_of_protected_river_improved_previous_years
    kilometres_of_protected_river_improved_2015
    kilometres_of_protected_river_improved_2016
    kilometres_of_protected_river_improved_2017
    kilometres_of_protected_river_improved_2018
    kilometres_of_protected_river_improved_2019
    kilometres_of_protected_river_improved_2020
    kilometres_of_protected_river_improved_2021
    kilometres_of_protected_river_improved_2022
    kilometres_of_protected_river_improved_2023
    kilometres_of_protected_river_improved_2024
    kilometres_of_protected_river_improved_2025
    kilometres_of_protected_river_improved_2026
    kilometres_of_protected_river_improved_2027
  ].freeze

  SPREADSHEET_UNUSED_COLUMNS = %i[
    packages
    ldw_cpw_idb_number
    lrma_project_reference
    parliamentary_constituencies_benefit_area
    agreed_strategy
    environmental_considerations
    new_builds
    scheme_comments
    additional_potential
    additional_funding_required_for_additional_benefits
    hectares_of_net_water_dependent_habitat_created_previous_years
    hectares_of_net_water_dependent_habitat_created_2015
    hectares_of_net_water_dependent_habitat_created_2016
    hectares_of_net_water_dependent_habitat_created_2017
    hectares_of_net_water_dependent_habitat_created_2018
    hectares_of_net_water_dependent_habitat_created_2019
    hectares_of_net_water_dependent_habitat_created_2020
    hectares_of_net_water_dependent_habitat_created_2021
    hectares_of_net_water_dependent_habitat_created_2022
    hectares_of_net_water_dependent_habitat_created_2023
    hectares_of_net_water_dependent_habitat_created_2024
    hectares_of_net_water_dependent_habitat_created_2025
    hectares_of_net_water_dependent_habitat_created_2026
    hectares_of_net_water_dependent_habitat_created_2027
    hectares_of_net_water_intertidal_habitat_created_previous_years
    hectares_of_net_water_intertidal_habitat_created_2015
    hectares_of_net_water_intertidal_habitat_created_2016
    hectares_of_net_water_intertidal_habitat_created_2017
    hectares_of_net_water_intertidal_habitat_created_2018
    hectares_of_net_water_intertidal_habitat_created_2019
    hectares_of_net_water_intertidal_habitat_created_2020
    hectares_of_net_water_intertidal_habitat_created_2021
    hectares_of_net_water_intertidal_habitat_created_2022
    hectares_of_net_water_intertidal_habitat_created_2023
    hectares_of_net_water_intertidal_habitat_created_2024
    hectares_of_net_water_intertidal_habitat_created_2025
    hectares_of_net_water_intertidal_habitat_created_2026
    hectares_of_net_water_intertidal_habitat_created_2027
    kilometres_of_protected_river_improved_previous_years
    kilometres_of_protected_river_improved_2015
    kilometres_of_protected_river_improved_2016
    kilometres_of_protected_river_improved_2017
    kilometres_of_protected_river_improved_2018
    kilometres_of_protected_river_improved_2019
    kilometres_of_protected_river_improved_2020
    kilometres_of_protected_river_improved_2021
    kilometres_of_protected_river_improved_2022
    kilometres_of_protected_river_improved_2023
    kilometres_of_protected_river_improved_2024
    kilometres_of_protected_river_improved_2025
    kilometres_of_protected_river_improved_2026
    kilometres_of_protected_river_improved_2027
  ].freeze

  SPREADSHEET_ADDITIONAL_COLUMNS = %i[
    project_executive
    project_manager
    project_record_owner
    project_status
    finance_category
    additional_function
    public_contributor_names
    private_contributor_names
    other_ea_contributor_names
  ].freeze

  SPREADSHEET_COLUMN_ORDER = [
    SPREADSHEET_BASIC_INFO,
    SPREADSHEET_STANDARD_OF_PROTECTION,
    SPREADSHEET_PF_CALCULATOR_FIGURES,
    SPREADSHEET_DATES,
    SPREADSHEET_TOTALS,
    SPREADSHEET_TOTAL_FIGURES,
    SPREADSHEET_GIA_FIGURES,
    SPREADSHEET_GROWTH_FIGURES,
    SPREADSHEET_LEVY_FIGURES,
    SPREADSHEET_IDB_FIGURES,
    SPREADSHEET_PUBLIC_FIGURES,
    SPREADSHEET_PRIVATE_FIGURES,
    SPREADSHEET_EA_FIGURES,
    SPREADSHEET_NYI_FIGURES,
    SPREADSHEET_FLOODING_FIGURES,
    SPREADSHEET_COASTAL_FIGURES,
    SPREADSHEET_OM4_COLUMNS,
    SPREADSHEET_WFD_INFO,
    SPREADSHEET_FUTURE_FIGURES,
    SPREADSHEET_SIX_YEAR_TOTALS,
    SPREADSHEET_ADDITIONAL_COLUMNS
  ].flatten.freeze
end
