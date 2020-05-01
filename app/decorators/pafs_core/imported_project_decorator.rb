# frozen_string_literal: true

module PafsCore
  class ImportedProjectDecorator < SimpleDelegator
    include PafsCore::EnvironmentalOutcomes
    include PafsCore::StandardOfProtection
    include PafsCore::Urgency
    include PafsCore::Outcomes
    include PafsCore::Risks
    include PafsCore::FundingSources

    def project_status=(value)
      PafsCore::Projects::StatusUpdate.new(project, value).perform
    end

    def confidence_homes_better_protected=(value)
      PafsCore::Projects::ConfidenceUpdate.new(project, value, :homes_better_protected).perform
    end

    def confidence_homes_by_gateway_four=(value)
      PafsCore::Projects::ConfidenceUpdate.new(project, value, :homes_by_gateway_four).perform
    end

    def confidence_secured_partnership_funding=(value)
      PafsCore::Projects::ConfidenceUpdate.new(project, value, :secured_partnership_funding).perform
    end

    def reference_number=(value)
      project.reference_number = value.upcase unless value.nil?
    end

    # name - straight map

    def rma_name=(value)
      # This is the area that owns the proposal
      area = PafsCore::Area.find_by(name: value)
      if area.nil?
        project.errors.add(:base, "^Cannot find area (rma_name: #{value})")
      else
        project.area_projects.delete_all
        project.area_projects.create(area_id: area.id, owner: true)
      end
    end

    # project_type - straight map

    def main_risk=(value)
      # map the main_risk - we are going to lose any other risks here
      r = risk_from_string(value)
      if r.nil?
        project.errors.add(:main_risk, "^No main risk specified")
      else
        project.send("#{r}=", true)
        project.main_risk = r
      end
    end

    def moderation_code=(value)
      # project is urgent by virtue of this having a value
      # urgency_reason derived from value
      if value.blank?
        project.urgency_reason = "not_urgent"
        project.urgency_details = nil
      else
        reason = urgency_from_string(value)
        if reason.nil?
          project.errors.add(:urgency_reason, "^Invalid urgency reason (moderation_code: #{value})")
        else
          project.urgency_reason = reason
        end
      end
    end

    def consented=(value)
      project.consented = (value == "Y" || value == "y")
    end

    def grid_reference=(value)
      # perform lookup and update location values
      if value.blank?
        project.errors.add(:grid_reference, "^No grid reference supplied")
      else
        gr = PafsCore::GridReference.new(value)
        if gr.valid?
          project.grid_reference = gr.to_s
          coords = gr.to_lat_lon
          begin
            data = map_service.fetch_location_data(coords[:latitude], coords[:longitude])
            project.region = data[:region]
            project.county = data[:county]
            project.parliamentary_constituency = data[:parliamentary_constituency]
          rescue PafsCore::MapServiceError => e
            project.errors.add(:grid_reference,
                               "^Unable to query for location information (#{e})")
          end
        else
          project.errors.add(:grid_reference, "^Invalid grid reference (#{value})")
        end
      end
    end

    # approach - straight map

    def flood_protection_before=(value)
      set_sop_value(:flood_protection_before, value, STANDARD_OF_PROTECTION_FLOODING)
    end

    def flood_protection_after=(value)
      set_sop_value(:flood_protection_after, value, STANDARD_OF_PROTECTION_FLOODING)
    end

    def coastal_protection_before=(value)
      set_sop_value(:coastal_protection_before, value, STANDARD_OF_PROTECTION_COASTAL_BEFORE)
    end

    def coastal_protection_after=(value)
      set_sop_value(:coastal_protection_after, value, STANDARD_OF_PROTECTION_COASTAL_AFTER)
    end

    def public_contributors=(value)
      project.public_contributions = !value&.strip.blank?
    end

    def private_contributors=(value)
      project.private_contributions = !value&.strip.blank?
    end

    def other_ea_contributors=(value)
      project.other_ea_contributions = !value&.strip.blank?
    end

    def earliest_start_date=(value)
      set_date_for(:earliest_start, value)
      project.could_start_early = !!(project.earliest_start_month && project.earliest_start_year)
    end

    def start_business_case_date=(value)
      set_date_for(:start_outline_business_case, value)
    end

    def award_contract_date=(value)
      set_date_for(:award_contract, value)
    end

    def start_construction_date=(value)
      set_date_for(:start_construction, value)
    end

    def ready_for_service_date=(value)
      set_date_for(:ready_for_service, value)
    end

    def fcerm_gia=(values)
      populate_funding_values_for(:fcerm_gia, values)
    end

    def growth_funding=(values)
      populate_funding_values_for(:growth_funding, values)
    end

    def local_levy=(values)
      populate_funding_values_for(:local_levy, values)
    end

    def internal_drainage_boards=(values)
      populate_funding_values_for(:internal_drainage_boards, values)
    end

    def public_contributions=(values)
      populate_funding_values_for(:public_contributions, values)
    end

    def private_contributions=(values)
      populate_funding_values_for(:private_contributions, values)
    end

    def other_ea_contributions=(values)
      populate_funding_values_for(:other_ea_contributions, values)
    end

    def not_yet_identified=(values)
      populate_funding_values_for(:not_yet_identified, values)
    end

    def households_at_reduced_risk=(values)
      populate_flood_protection_outcome_for(:households_at_reduced_risk, values)
    end

    def moved_from_very_significant_and_significant_to_moderate_or_low=(values)
      populate_flood_protection_outcome_for(:moved_from_very_significant_and_significant_to_moderate_or_low, values)
    end

    def households_protected_from_loss_in_20_percent_most_deprived=(values)
      populate_flood_protection_outcome_for(:households_protected_from_loss_in_20_percent_most_deprived, values)
    end

    def coastal_households_at_reduced_risk=(values)
      populate_coastal_erosion_outcome_for(:households_at_reduced_risk, values)
    end

    def coastal_households_protected_from_loss_in_next_20_years=(values)
      populate_coastal_erosion_outcome_for(:households_protected_from_loss_in_next_20_years, values)
    end

    def coastal_households_protected_from_loss_in_20_percent_most_deprived=(values)
      populate_coastal_erosion_outcome_for(:households_protected_from_loss_in_20_percent_most_deprived, values)
    end

    def designated_site=(value)
      project.improve_spa_or_sac = value == "SPA/SAC"
      project.improve_sssi = value == "SSSI"
    end

    def improve_surface_or_groundwater_amount=(value)
      project.improve_surface_or_groundwater = !(value.nil? || value.to_i == 0)
      project.improve_surface_or_groundwater_amount = value
    end

    def remove_fish_or_eel_barrier=(value)
      if value == "Both"
        project.remove_fish_barrier = project.remove_eel_barrier = true
      else
        project.remove_fish_barrier = value == "Fish"
        project.remove_eel_barrier = value == "Eel"
      end
    end

    # fish_or_eel_amount straight map

    def improve_river_amount=(value)
      if value.nil? || value.to_i == 0
        project.improve_river = false
        project.improve_river_amount = 0
      else
        project.improve_river = true
        project.improve_river_amount = value.to_i
      end
    end

    # improve_habitat_amount - straight map

    def create_habitat_amount=(value)
      if value.nil? || value.to_i == 0
        project.create_habitat = false
        project.create_habitat_amount = 0
      else
        project.create_habitat = true
        project.create_habitat_amount = value.to_i
      end
    end

    # ###########################################################3

    # prevent navigator falling over and giving us non-javascript steps
    def javascript_disabled?
      false
    end

    private

    def project
      __getobj__
    end

    def map_service
      @map_service ||= PafsCore::MapService.new
    end

    def set_date_for(sym, value)
      if value.blank?
        project.errors.add("#{sym}_date".to_sym, "^#{sym.to_s.titlecase} date not supplied")
      elsif value.respond_to?(:month) && value.respond_to?(:year)
        project.send("#{sym}_month=", value.month)
        project.send("#{sym}_year=", value.year)
      else
        d = value.split("/")
        if d.size == 3
          # day / month /year
          project.send("#{sym}_month=", d[1])
          project.send("#{sym}_year=", d[2])
        elsif d.size == 2
          # month / year
          project.send("#{sym}_month=", d[0])
          project.send("#{sym}_year=", d[1])
        else
          # an error then
          project.errors.add("#{sym}_date".to_sym, "^#{sym.to_s.titlecase} date not recognised (#{value})")
        end
      end
    end

    def populate_funding_values_for(fv_type, values)
      return if AGGREGATE_SOURCES.include?(fv_type)

      [-1].concat((2015..2027).to_a).each_with_index do |year, i|
        fv = project.funding_values.find_or_create_by(financial_year: year)
        fv.send("#{fv_type}=", values[i])
        fv.save
      end
      project.send("#{fv_type}=", (values.sum > 0))
    end

    def populate_flood_protection_outcome_for(fpo_type, values)
      [-1].concat((2015..2027).to_a).each_with_index do |year, i|
        fpo = project.flood_protection_outcomes.find_or_create_by(financial_year: year)
        fpo.send("#{fpo_type}=", values[i])
        fpo.save
      end
    end

    def populate_coastal_erosion_outcome_for(cepo_type, values)
      [-1].concat((2015..2027).to_a).each_with_index do |year, i|
        cepo = project.coastal_erosion_protection_outcomes.find_or_create_by(financial_year: year)
        cepo.send("#{cepo_type}=", values[i])
        cepo.save
      end
    end

    def set_sop_value(category, value, ary)
      if value.blank? || value == "BLANK"
        project.send("#{category}=", nil)
      else
        val = sop_from_string(value)
        if val.nil?
          project.errors.add(category,
                             "^Invalid '#{category.to_s.titlecase}' value (#{value})")
        else
          idx = ary.find_index(val)
          if idx.nil?
            project.errors.add(category,
                               "^Invalid '#{category.to_s.titlecase}' value (#{value})")
          else
            project.send("#{category}=", idx)
          end
        end
      end
    end
  end
end
