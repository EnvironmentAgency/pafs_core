# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ProjectSummaryPresenter < SimpleDelegator

    def project_type_name
      if project_type.present?
        I18n.t(project_type.downcase, scope: "pafs_core.project_types")
      else
        ""
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

    def funding_sources
      fs = []
      fs << "FCERM GiA" if fcerm_gia
      fs << "Local levy" if local_levy
      fs << "Internal drainage boards" if internal_drainage_boards
      fs << "Public contributions" if public_contributions
      fs << "Private contributions" if private_contributions
      fs << "Other EA contributions" if other_ea_contributions
      fs << "Growth funding" if growth_funding
      fs << "Not yet identified" if not_yet_identified
      fs
    end

    def risks
      r = []
      r << :fluvial_flooding if fluvial_flooding?
      r << :tidal_flooding if tidal_flooding?
      r << :groundwater_flooding if groundwater_flooding?
      r << :surface_water_flooding if surface_water_flooding?
      r << :coastal_erosion if coastal_erosion?
      r
    end

    def is_main_risk?(risk)
      main_risk.present? && main_risk == risk.to_s
    end

    def early_start_date_or_no
      if could_start_early?
        presentable_date(:earliest_start)
      else
        "No"
      end
    end

    private
    def presentable_date(name)
      m = send("#{name}_month")
      y = send("#{name}_year")
      # FIXME: can we do better than 'not set'?
      return "not set" if m.nil? || y.nil?
      Date.new(y, m, 1).strftime("%B %Y") # Month-name Year
    end
  end
end
