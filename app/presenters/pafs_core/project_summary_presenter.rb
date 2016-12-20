# frozen_string_literal: true
module PafsCore
  class ProjectSummaryPresenter < SimpleDelegator
    include PafsCore::FundingSources, PafsCore::Risks, PafsCore::Outcomes,
      PafsCore::Urgency, PafsCore::StandardOfProtection,
      PafsCore::EnvironmentalOutcomes

    def location_set?
      project.grid_reference.present?
    end

    def benefit_area_file_uploaded?
      benefit_area_file_name.present?
    end

    def grid_reference
      if project.grid_reference
        p = project.grid_reference.delete("\s")
        "#{p[0..1]} #{p[2..6]} #{p[7..11]}"
      else
        ""
      end
    end

    def show_location_data?
      ENV.fetch("SHOW_LOCATION_DATA", false) != false
    end

    def grid_reference_link
      if project.grid_reference
        I18n.t("see_this_location_link",
               grid_reference: CGI::escape(grid_reference))
      else
        "#"
      end
    end

    def start_outline_business_case_date
      presentable_date(:start_outline_business_case)
    end

    def award_contract_date
      presentable_date(:award_contract)
    end

    def start_construction_date
      presentable_date(:start_construction)
    end

    def ready_for_service_date
      presentable_date(:ready_for_service)
    end

    def earliest_start_date
      presentable_date(:earliest_start)
    end

    def key_dates_started?
      start_outline_business_case_month.present? ||
        award_contract_month.present? ||
        start_construction_month.present? ||
        ready_for_service_month.present?
    end

    def funding_sources_started?
      funding_sources_visited?
    end

    def earliest_start_started?
      !could_start_early.nil?
    end

    def risks_started?
      selected_risks.count > 0
    end

    def standard_of_protection_started?
      flood_protection_before.present? || flood_protection_after.present? ||
        coastal_protection_before.present? || coastal_protection_after.present?
    end

    def standard_of_protection_step
      if protects_against_flooding?
        :standard_of_protection
      elsif protects_against_coastal_erosion?
        :standard_of_protection_coastal
      else
        raise "Risks not set prior to standard of protection"
      end
    end

    def flood_protection_before_percentage
      if flood_protection_before.present?
        standard_of_protection_label(flood_risk_options[flood_protection_before])
      else
        not_provided
      end
    end

    def flood_protection_after_percentage
      if flood_protection_after.present?
        standard_of_protection_label(flood_risk_options[flood_protection_after])
      else
        not_provided
      end
    end

    def coastal_protection_before_years
      if coastal_protection_before.present?
        standard_of_protection_label(coastal_erosion_before_options[coastal_protection_before])
      else
        not_provided
      end
    end

    def coastal_protection_after_years
      if coastal_protection_after.present?
        standard_of_protection_label(coastal_erosion_after_options[coastal_protection_after])
      else
        not_provided
      end
    end

    def flood_protection_outcomes_entered?
      flood_protection_outcomes.count > 0
    end

    def coastal_erosion_protection_outcomes_entered?
      coastal_erosion_protection_outcomes.count > 0
    end

    def environmental_outcomes_started?
      !improve_surface_or_groundwater.nil? || !improve_spa_or_sac.nil? ||
        !improve_sssi.nil? || !improve_hpi.nil? || !improve_river.nil? ||
        !create_habitat.nil? || !remove_fish_barrier.nil? ||
        !remove_eel_barrier.nil?
    end

    def surface_and_groundwater_size
      return km(0) unless improve_surface_or_groundwater?
      km(improve_surface_or_groundwater_amount)
    end

    def improve_habitat_size
      if improves_habitat?
        ha(improve_habitat_amount)
      else
        ha(0)
      end
    end

    def improve_river_size
      return km(0) unless (improves_habitat? && improve_river.nil?) || improve_river?
      km(improve_river_amount)
    end

    def create_habitat_size
      return ha(0) unless create_habitat.nil? || create_habitat?
      ha(create_habitat_amount)
    end

    def fish_or_eel_passage_size
      if removes_fish_or_eel_barrier?
        km(fish_or_eel_amount)
      else
        km(0)
      end
    end

    def km(n)
      return not_provided if n.blank?
      "#{squish_int_float(n)} kilometres"
    end

    def ha(n)
      return not_provided if n.blank?
      "#{squish_int_float(n)} hectares"
    end

    def funding
      selected_funding_sources.map do |fs|
        {
          name: funding_source_label(fs),
          value: total_for(fs)
        }
      end
    end

    def submission_date
      # TODO: return the formatted submission date or "Proposal not submitted"
      "Proposal not submitted"
    end

    def is_main_risk?(risk)
      main_risk.present? && main_risk == risk.to_s
    end

    def total_for_flooding_a
      return not_provided unless flood_protection_outcomes_entered?
      total_fpo_for(:households_at_reduced_risk)
    end

    def total_for_flooding_b
      return not_provided unless flood_protection_outcomes_entered?
      total_fpo_for(:moved_from_very_significant_and_significant_to_moderate_or_low)
    end

    def total_for_flooding_c
      return not_provided unless flood_protection_outcomes_entered?
      total_fpo_for(:households_protected_from_loss_in_20_percent_most_deprived)
    end

    def total_for_coastal_a
      return not_provided unless coastal_erosion_protection_outcomes_entered?
      total_ce_for(:households_at_reduced_risk)
    end

    def total_for_coastal_b
      return not_provided unless coastal_erosion_protection_outcomes_entered?
      total_ce_for(:households_protected_from_loss_in_next_20_years)
    end

    def total_for_coastal_c
      return not_provided unless coastal_erosion_protection_outcomes_entered?
      total_ce_for(:households_protected_from_loss_in_20_percent_most_deprived)
    end

    def funding_calculator_uploaded?
      funding_calculator_file_name.present?
    end

    def summary_label(id)
      I18n.t(id.to_s, scope: "pafs_core.summary")
    end

    def articles
      if project_protects_households?
        if risks_started?
          all_articles
        else
          all_articles - [:standard_of_protection]
        end
      else
        all_articles - [:risks, :standard_of_protection]
      end
    end

    def not_provided
      "<em>Not provided</em>".html_safe
    end

    private
    def project
      __getobj__
    end

    def squish_int_float(v)
      (v.to_int if v.is_a?(Float) && v % 1 == 0) || v
    end

    def all_articles
      [:project_name,
       :project_type,
       :financial_year,
       :location,
       :key_dates,
       :funding_sources,
       :earliest_start,
       :risks,
       :standard_of_protection,
       :approach,
       :environmental_outcomes,
       :urgency,
       :funding_calculator].freeze
    end

    def presentable_date(name)
      m = send("#{name}_month")
      y = send("#{name}_year")
      return not_provided if m.nil? || y.nil?
      Date.new(y, m, 1).strftime("%B %Y") # Month-name Year
    end
  end
end
