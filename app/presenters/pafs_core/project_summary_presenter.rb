# frozen_string_literal: true
module PafsCore
  class ProjectSummaryPresenter < SimpleDelegator
    include PafsCore::FundingSources

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

    def funding
      funding = []
      selected_funding_sources.each do |fs|
        funding << { name: funding_source_label(fs),
                     value: total_for(fs) }
      end
      funding
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
