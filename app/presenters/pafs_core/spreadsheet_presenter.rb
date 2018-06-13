# frozen_string_literal: true
module PafsCore
  class SpreadsheetPresenter < SimpleDelegator
    include PafsCore::FundingSources, PafsCore::Risks,
      PafsCore::Outcomes, PafsCore::Urgency, PafsCore::StandardOfProtection,
      PafsCore::EnvironmentalOutcomes

    # name
    # reference_number
    # region

    def rfcc
      RFCC_CODE_NAMES_MAP.fetch(reference_number[0, 2])
    end

    def ea_area
      owning_area = owner
      if owning_area
        until owning_area.ea_area? do
          owning_area = owning_area.parent
        end
        owning_area.name
      end
    end

    def rma_name
      owning_area = owner
      owning_area.name if owning_area && (owning_area.rma? || owning_area.pso_area?)
    end

    def rma_type
      owning_area = owner
      owning_area.sub_type if owning_area && owning_area.rma?
    end

    def coastal_group
      if coastal_erosion? || sea_flooding? || tidal_flooding?
        owning_area = owner
        if owning_area
          owning_area = owning_area.parent if owning_area.rma?
          PSO_TO_COASTAL_GROUP_MAP.fetch(owning_area.name, nil)
        end
      end
    end

    def project_type
      if project.project_type && project.project_type.start_with?("ENV")
        "ENV"
      else
        project.project_type
      end
    end

    def main_risk
      I18n.t(project.main_risk, scope: "pafs_core.fcerm1.risks") unless project.main_risk.nil?
    end

    def moderation_code
      if urgent?
        I18n.t(project.urgency_reason, scope: "pafs_core.fcerm1.moderation")
      else
        ""
      end
    end

    def consented
      y_or_n project.consented?
    end

    def grid_reference
      PafsCore::GridReference.new(project.grid_reference).to_s unless project.grid_reference.nil?
    end

    # county
    # parliamentary constituency
    # approach

    def flood_protection_before
      sop_label(flood_risk_symbol(project.flood_protection_before)) unless project.flood_protection_before.nil?
    end

    def flood_protection_after
      sop_label(flood_risk_symbol(project.flood_protection_after)) unless project.flood_protection_after.nil?
    end

    def coastal_protection_before
      sop_label(coastal_risk_before_symbol(project.coastal_protection_before)) unless
      project.coastal_protection_before.nil?
    end

    def coastal_protection_after
      sop_label(coastal_risk_after_symbol(project.coastal_protection_after)) unless
      project.coastal_protection_after.nil?
    end

    # PF calc values
    def strategic_approach
      y_or_n project.strategic_approach
    end
    # raw_partnership_funding_score
    # adjusted_partnership_funding_score
    # pv_whole_life_costs
    # pv_whole_life_benefits

    def benefit_cost_ratio
      (pv_whole_life_benefits / pv_whole_life_costs).round(1) if pv_whole_life_benefits && pv_whole_life_costs
    end

    def public_contributors
      public_contributor_names if public_contributions?
    end

    def private_contributors
      private_contributor_names if private_contributions?
    end

    def other_ea_contributors
      other_ea_contributor_names if other_ea_contributions?
    end

    def earliest_start_date
      format_2_part_date(:earliest_start) if could_start_early?
    end

    def start_business_case_date
      format_2_part_date(:start_outline_business_case)
    end

    def award_contract_date
      format_2_part_date(:award_contract)
    end

    def start_construction_date
      format_2_part_date(:start_construction)
    end

    def ready_for_service_date
      format_2_part_date(:ready_for_service)
    end

    def fcerm_gia(year)
      funding_for(year).sum(:fcerm_gia)
    end

    def growth_funding(year)
      funding_for(year).sum(:growth_funding)
    end

    def local_levy(year)
      funding_for(year).sum(:local_levy)
    end

    def internal_drainage_boards(year)
      funding_for(year).sum(:internal_drainage_boards)
    end

    def public_contributions(year)
      funding_for(year).sum(:public_contributions)
    end

    def private_contributions(year)
      funding_for(year).sum(:private_contributions)
    end

    def other_ea_contributions(year)
      funding_for(year).sum(:other_ea_contributions)
    end

    def not_yet_identified(year)
      funding_for(year).sum(:not_yet_identified)
    end

    def households_at_reduced_risk(year)
      sum_flood_protection_for(year, :households_at_reduced_risk)
    end

    def moved_from_very_significant_and_significant_to_moderate_or_low(year)
      sum_flood_protection_for(year, :moved_from_very_significant_and_significant_to_moderate_or_low)
    end

    def households_protected_from_loss_in_20_percent_most_deprived(year)
      sum_flood_protection_for(year, :households_protected_from_loss_in_20_percent_most_deprived)
    end

    def coastal_households_at_reduced_risk(year)
      sum_coastal_erosion_protection_for(year, :households_at_reduced_risk)
    end

    def coastal_households_protected_from_loss_in_next_20_years(year)
      sum_coastal_erosion_protection_for(year, :households_protected_from_loss_in_next_20_years)
    end

    def coastal_households_protected_from_loss_in_20_percent_most_deprived(year)
      sum_coastal_erosion_protection_for(year, :households_protected_from_loss_in_20_percent_most_deprived)
    end

    def hectares_of_net_water_dependent_habitat_created
      project.hectares_of_net_water_dependent_habitat_created || 0
    end

    def hectares_of_net_water_intertidal_habitat_created
      project.hectares_of_net_water_intertidal_habitat_created || 0
    end

    def kilometres_of_protected_river_improved
      project.kilometres_of_protected_river_improved || 0
    end

    def designated_site
      if improve_spa_or_sac?
        "SPA/SAC"
      elsif improve_sssi?
        "SSSI"
      else
        "None"
      end
    end

    def improve_surface_or_groundwater_amount
      if improve_surface_or_groundwater?
        project.improve_surface_or_groundwater_amount || 0
      else
        0
      end
    end

    def remove_fish_or_eel_barrier
      if remove_fish_barrier? && remove_eel_barrier?
        "Both"
      elsif remove_fish_barrier?
        "Fish"
      elsif remove_eel_barrier?
        "Eel"
      else
        "None"
      end
    end

    def fish_or_eel_amount
      if removes_fish_or_eel_barrier?
        project.fish_or_eel_amount || 0
      else
        0
      end
    end

    def improve_river_amount
      if improve_river?
        project.improve_river_amount || 0
      else
        0
      end
    end

    def improve_habitat_amount
      if improves_habitat?
        project.improve_habitat_amount || 0
      else
        0
      end
    end

    def create_habitat_amount
      if create_habitat?
        project.create_habitat_amount || 0
      else
        0
      end
    end

    def project_status
      project.status
    end

    private
    def project
      __getobj__
    end

    def funding_for(year)
      if year > 2026
        # sum up 2027 onwards for spreadsheet
        t = PafsCore::FundingValue.arel_table
        project.funding_values.where(t[:financial_year].gt(year - 1))
      else
        project.funding_values.where(financial_year: year)
      end
    end

    def flood_protection_for(year)
      if year > 2026
        # sum up 2027 onwards for spreadsheet
        t = PafsCore::FloodProtectionOutcome.arel_table
        project.flood_protection_outcomes.where(t[:financial_year].gt(year - 1))
      else
        project.flood_protection_outcomes.where(financial_year: year)
      end
    end

    def coastal_erosion_protection_for(year)
      if year > 2026
        # sum up 2027 onwards for spreadsheet
        t = PafsCore::CoastalErosionProtectionOutcome.arel_table
        project.coastal_erosion_protection_outcomes.where(t[:financial_year].gt(year - 1))
      else
        project.coastal_erosion_protection_outcomes.where(financial_year: year)
      end
    end

    def sum_flood_protection_for(year, category)
      return 0 if year > project.project_end_financial_year
      flood_protection_for(year).sum(category)
    end

    def sum_coastal_erosion_protection_for(year, category)
      return 0 if year > project.project_end_financial_year
      coastal_erosion_protection_for(year).sum(category)
    end

    def format_2_part_date(dt)
      if project.send("#{dt}_month") && project.send("#{dt}_year")
        "%02d/%d" % [project.send("#{dt}_month"), project.send("#{dt}_year")]
      end
    end

    def squish_int_float(v)
      (v.to_int if v.is_a?(Float) && v % 1 == 0) || v
    end

    def presentable_date(name)
      m = send("#{name}_month")
      y = send("#{name}_year")
      return not_provided if m.nil? || y.nil?
      Date.new(y, m, 1).strftime("%B %Y") # Month-name Year
    end

    def sop_label(value)
      I18n.t(value, scope: "pafs_core.fcerm1.standard_of_protection") unless value.nil?
    end

    def y_or_n(val)
      val ? "Y" : "N"
    end
  end
end
