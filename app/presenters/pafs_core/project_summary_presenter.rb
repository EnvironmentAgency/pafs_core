# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ProjectSummaryPresenter < SimpleDelegator

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

    def early_start_date_or_no
      if could_start_early?
        presentable_date(:earliest_start)
      else
        "No"
      end
    end

    def self.wrap(collection)
      collection.map { |obj| new(obj) }
    end

    private
    def presentable_date(name)
      m = send("#{name}_month")
      y = send("#{name}_year")
      return "not set" if m.nil? || y.nil?
      Date.new(y, m, 1).strftime("%B %Y") # Month-name Year
    end
  end
end
