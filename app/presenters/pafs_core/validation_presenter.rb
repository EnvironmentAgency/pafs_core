# frozen_string_literal: true
module PafsCore
  class ValidationPresenter < PafsCore::ProjectSummaryPresenter
    include PafsCore::FundingSources

    def complete?
      result = true
      articles_to_validate.each do |article|
        complete = send "#{article}_complete?"
        result &&= complete
      end
      result
    end

    def project_name_complete?
      # NOTE: currently has to be present before creation
      true
    end

    def project_type_complete?
      # NOTE: currently has to be present before creation
      true
    end

    def financial_year_complete?
      # NOTE: currently has to be present before creation
      true
    end

    def location_complete?
      if location_set? && benefit_area_file_uploaded?
        true
      else
        add_error(:location, "^Tell us the location of the project")
      end
    end

    def key_dates_complete?
      if start_outline_business_case_month.present? &&
         award_contract_month.present? &&
         start_construction_month.present? &&
         ready_for_service_month.present?
        true
      else
        add_error(:key_dates, "^Tell us the project's important dates")
      end
    end

    def funding_sources_complete?
      return true if funding_values_complete?

      add_error(:funding_sources, "^Tell us the project's funding sources and estimated spend")
    end

    def earliest_start_complete?
      if could_start_early.nil?
        add_error(:earliest_start, "^Tell us the earliest date the project can start")
      elsif could_start_early?
        if earliest_start_month.present? && earliest_start_year.present?
          true
        else
          add_error(:earliest_start, "^Tell us the earliest date the project can start")
        end
      else
        true
      end
    end

    def risks_complete?
      if selected_risks.any?
        if protects_against_multiple_risks?
          if main_risk.nil?
            risks_error
          elsif protects_against_flooding? && protects_against_coastal_erosion?
            check_flooding && check_coastal_erosion
          elsif protects_against_flooding?
            check_flooding
          else
            # this must be only protecting against coastal erosion to get here
            check_coastal_erosion
          end
        elsif protects_against_flooding?
          check_flooding
        else
          check_coastal_erosion
        end
      else
        risks_error
      end
    end

    def standard_of_protection_complete?
      if protects_against_flooding?
        if flood_protection_before.nil? || flood_protection_after.nil?
          return add_error(:standard_of_protection,
                           "^Tell us the standard of protection the project will provide")
        end
      end

      if protects_against_coastal_erosion?
        if coastal_protection_before.nil? || coastal_protection_after.nil?
          return add_error(:standard_of_protection,
                           "^Tell us the standard of protection the project will provide")
        end
      end
      true
    end

    def approach_complete?
      if approach.blank?
        add_error(:approach, "^Tell us how the project will achieve its goals")
      else
        true
      end
    end

    def environmental_outcomes_complete?
      check_surface_or_groundwater &&
        check_spa_sac_and_sssi &&
        check_improves_habitat &&
        check_create_habitat &&
        check_fish_and_eels
    end

    def check_surface_or_groundwater
      if improve_surface_or_groundwater.nil?
        outcomes_error
      elsif improve_surface_or_groundwater? && improve_surface_or_groundwater_amount.nil?
        outcomes_error
      else
        true
      end
    end

    def check_spa_sac_and_sssi
      return outcomes_error if improve_spa_or_sac.nil?

      unless improve_spa_or_sac?
        return outcomes_error if improve_sssi.nil?

        unless improve_sssi?
          return outcomes_error if improve_hpi.nil?
        end
      end
      true
    end

    def check_improves_habitat
      if improves_habitat?
        if improve_habitat_amount.nil? || improve_river.nil? || (improve_river? && improve_river_amount.nil?)
          return outcomes_error
        end
      end
      true
    end

    def check_create_habitat
      if create_habitat.nil? || (create_habitat? && create_habitat_amount.nil?)
        outcomes_error
      else
        true
      end
    end

    def check_fish_and_eels
      if remove_fish_barrier.nil? || remove_eel_barrier.nil?
        outcomes_error
      elsif (remove_fish_barrier? || remove_eel_barrier?) && fish_or_eel_amount.nil?
        outcomes_error
      else
        true
      end
    end

    def urgency_complete?
      if urgency_reason.nil?
        add_error(:urgency, "^Tell us whether the project is urgent")
      elsif urgent? && urgency_details.blank?
        add_error(:urgency, "^Tell us whether the project is urgent")
      else
        true
      end
    end

    def funding_calculator_complete?
      if funding_calculator_file_name.blank?
        add_error(:funding_calculator, "^Upload the project's partnership funding calculator")
      else
        true
      end
    end

    def articles_to_validate
      if project_protects_households?
        all_articles
      else
        all_articles - [:risks, :standard_of_protection]
      end
    end

    def funding_values_complete?
      return false unless selected_funding_sources.present?

      selected_funding_sources.all? { |fs| total_for(fs) > 0 }
    end

    def add_error(attr, msg)
      project.errors.add(attr, msg)
      false
    end

    def outcomes_error
      add_error(:environmental_outcomes,
                "^Tell us the project’s environmental outcomes")
    end

    def check_flooding
      if flooding_total_protected_households > 0 || project.reduced_risk_of_households_for_floods?
        true
      else
        risks_error
      end
    end

    def check_coastal_erosion
      if coastal_total_protected_households > 0 || project.reduced_risk_of_households_for_coastal_erosion?
        true
      else
        risks_error
      end
    end

    def risks_error
      add_error(:risks,
                "^Tell us the risks the project protects against "\
                "and the households benefiting.")
      false
    end
  end
end
