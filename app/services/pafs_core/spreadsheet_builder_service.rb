# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class SpreadsheetBuilderService
    require "csv"
    require "axlsx"
    include PafsCore::StandardOfProtection

    NEXT_FINANCIAL_YEAR = 1.year.from_now.uk_financial_year

    def generate_csv(projects)
      records = get_records(projects)
      processed_records = process_records(records)
      create_csv(processed_records)
    end

    def generate_xlsx(projects)
      records = get_records(projects)
      processed_records = process_records(records)
      create_xlsx(processed_records)
    end

    def project_ids(projects)
      if projects.empty?
        "NULL"
      else
        projects.map(&:id).join(",")
      end
    end

    def get_records(projects)
      sql = "SELECT #{PafsCore::SQL_COLUMNS_FOR_SPREADSHEET.join(',')},
      a.name AS area_name, a.area_type AS area_type, a.sub_type AS area_sub_type,
      a2.name AS parent_area_name, a2.area_type AS parent_area_type,
      a3.name AS grandparent_area_name, a3.area_type AS grandparent_area_type
      FROM pafs_core_projects p
      JOIN pafs_core_area_projects ap
      ON p.id = ap.project_id
      JOIN pafs_core_areas a
      ON ap.area_id = a.id
      JOIN pafs_core_areas a2
      ON a2.id = a.parent_id
      JOIN pafs_core_areas a3
      ON a3.id = a2.parent_id
      LEFT JOIN ( SELECT project_id,
        json_agg(row_to_json(row(financial_year, fcerm_gia))) AS gia_list,
        json_agg(row_to_json(row(financial_year, local_levy))) AS levy_list,
        json_agg(row_to_json(row(financial_year, internal_drainage_boards))) AS idb_list,
        json_agg(row_to_json(row(financial_year, public_contributions))) AS public_list,
        json_agg(row_to_json(row(financial_year, private_contributions))) AS private_list,
        json_agg(row_to_json(row(financial_year, other_ea_contributions))) AS ea_list,
        json_agg(row_to_json(row(financial_year, growth_funding))) AS growth_list,
        json_agg(row_to_json(row(financial_year, not_yet_identified))) AS nyi_list,
        json_agg(row_to_json(row(financial_year, total))) AS total_list
        FROM (SELECT * FROM pafs_core_funding_values) AS funding_values
        GROUP BY project_id) as fvs
      ON p.id = fvs.project_id
      LEFT JOIN ( SELECT project_id as pid,
        json_agg(row_to_json(row(financial_year, households_at_reduced_risk)))
        AS flood_households,
        json_agg(row_to_json(row(financial_year, moved_from_very_significant_and_significant_to_moderate_or_low)))
        AS flood_households_moved,
        json_agg(row_to_json(row(financial_year, households_protected_from_loss_in_20_percent_most_deprived)))
        AS flood_most_deprived
        FROM (SELECT * FROM pafs_core_flood_protection_outcomes) as flood_outcomes
        GROUP BY pid) as fpo
      ON p.id = fpo.pid
      LEFT JOIN ( SELECT project_id as pid,
        json_agg(row_to_json(row(financial_year, households_at_reduced_risk)))
        AS coastal_households,
        json_agg(row_to_json(row(financial_year, households_protected_from_loss_in_next_20_years)))
        AS coastal_households_protected,
        json_agg(row_to_json(row(financial_year, households_protected_from_loss_in_20_percent_most_deprived)))
        AS coastal_most_deprived
        FROM (SELECT * FROM pafs_core_coastal_erosion_protection_outcomes) as coastal_outcomes
        GROUP BY pid) as cepo
      ON p.id = cepo.pid
      WHERE p.id IN (#{project_ids(projects)})
      AND ap.owner = true"

      records = ActiveRecord::Base.connection.execute(sql).to_a
    end

    def process_records(records)
      projects = []

      records.each do |record|
        project = process_record(record)
        projects << project
      end

      projects
    end

    def process_record(record)
      processed_record = {}
      straightforward_data = extract_straightforward_data(record)
      processed_record.merge!(straightforward_data)
      processed_record.merge!(process_flood_protection(record))
      processed_record.merge!(process_coastal_protection(record))
      processed_record[:remove_fish_or_eel_barrier] = remove_fish_or_eel_barrier?(record)
      processed_record[:rfcc] = rfcc_name(record["reference_number"])
      processed_record[:coastal_group] = add_coastal_group(record)
      processed_record[:improve_sssi_sac_or_spa] = improve_sac_or_sssi?(record)
      processed_record.merge!(add_lead_rma(record))
      processed_record.merge!(process_geo_data(record))
      processed_record.merge!(process_funding_totals(record))
      processed_record.merge!(process_households_totals(record))
      processed_record.merge!(process_funding_six_year_totals(record))
      processed_record[:households_six_year_total] = process_households_six_year_totals(record)
      processed_record.merge!(year_by_year_breakdowns(record))
      processed_record.merge!(households_year_by_year_breakdowns(record))
      processed_record.merge!(process_future_funding_totals(record))
      processed_record.merge!(process_future_household_totals(record))
      processed_record.merge!(process_dates(record))
    end

    def extract_straightforward_data(record)
      keys = %w(
        name
        reference_number
        project_type
        approach
        region
        parliamentary_constituency
        improve_surface_or_groundwater_amount
        improve_habitat_amount
        improve_river_amount
        create_habitat
        create_habitat_amount
        fish_or_eel_amount
      )

      risk_urgency_keys = %w(urgency_reason main_risk)

      extracted_data = {}

      keys.each do |key|
        extracted_data[key.to_sym] = record[key]
      end

      risk_urgency_keys.each do |key|
        extracted_data[key.to_sym] = record[key].to_s.humanize
      end

      extracted_data
    end

    def remove_fish_or_eel_barrier?(record)
      record["remove_eel_barrier"] == "t" || record["remove_fish_barrier"] == "t"
    end

    def improve_sac_or_sssi?(record)
      record["improve_sssi"] == "t" || record["improve_spa_or_sac"] == "t"
    end

    def process_flood_protection(record)
      keys = %w(flood_protection_before flood_protection_after)
      flood_protection = {}
      keys.each do |key|
        sop = 999
        sop = record[key].to_i if !record[key].nil?
        flood_protection[key.to_sym] = flood_risk_options.fetch(sop, nil)
      end

      flood_protection.each { |k, v| flood_protection[k] = standard_of_protection_label(v) unless v.nil? }
      flood_protection
    end

    def process_coastal_protection(record)
      keys = %w(coastal_protection_before coastal_protection_after)
      protection = {}
      cpa = 999
      cpb = 999
      cpb = record["coastal_protection_before"].to_i
      cpa = record["coastal_protection_after"].to_i
      protection[:coastal_protection_before] = coastal_erosion_before_options.fetch(cpb, nil)
      protection[:coastal_protection_after] = coastal_erosion_after_options.fetch(cpa, nil)

      protection.each { |k, v| protection[k] = standard_of_protection_label(v) unless v.nil? }
      protection
    end

    def rfcc_name(project_number)
      rfcc_code = project_number[0, 2]
      PafsCore::RFCC_CODE_NAMES_MAP.fetch(rfcc_code)
    end

    def add_coastal_group(record)
      coastal_group = nil
      if coastal?(record)
        pso_area = get_pso_area(record)
        coastal_group = PafsCore::PSO_TO_COASTAL_GROUP_MAP.fetch(pso_area, nil)
      end

      coastal_group
    end

    def coastal?(record)
      coastal_types = %w(coastal_erosion sea_flooding tidal_flooding)
      coastal = false
      coastal_types.each { |c| coastal = true if record[c] == "t"}
      coastal
    end

    def get_pso_area(record)
      pso_area =  if record["area_type"] == "PSO Area"
                    record["area_name"]
                  else
                    record["parent_area_name"]
                  end
    end

    def add_lead_rma(record)
      lead_rma = nil
      lead_rma_type = nil
      if record["area_type"] == "RMA"
        lead_rma = record["area_name"]
        lead_rma_type = record["area_sub_type"]
      end

      { lead_rma: lead_rma, lead_rma_type: lead_rma_type }
    end

    def process_geo_data(record)
      location = record["project_location"].scan(/\d+/).map(&:to_i)
      grid_ref = nil
      grid_ref = Cumberland.get_grid_reference_from_coordinates(location[0], location[1]) if location.size == 2
      ea_area = if record["parent_area_type"] == "EA Area"
                  record["parent_area_name"]
                else
                  record["grandparent_area_name"]
                end
      { grid_ref: grid_ref, ea_area: ea_area, project_location: location }
    end

    def process_funding_totals(record)
      totals_hash = {}
      funding_sources = %w(gia levy idb public private ea growth nyi total)
      funding_sources.each do |fs|
        total = nil
        total = process_total(record["#{fs}_list"]) if record["#{fs}_list"].present?
        symbol = "#{fs}_total".to_sym
        totals_hash[symbol] = total
      end

      totals_hash
    end

    def process_households_totals(record)
      keys = %w(
        flood_households
        flood_households_moved
        flood_most_deprived
        coastal_households
        coastal_households_protected
        coastal_most_deprived
      )

      totals_hash = {}

      keys.each do |key|
        total = nil
        total = process_total(record[key]) if record[key].present?
        symbol = "#{key}_total".to_sym
        totals_hash[symbol] = total
      end

      totals_hash
    end

    def process_total(array)
      array = JSON.parse(array)
      total = 0
      array.each { |e| total += e["f2"].to_i }
      total = nil if total.zero?
      total
    end

    def process_funding_six_year_totals(record)
      totals_hash = {}
      funding_sources = %w(gia total)
      funding_sources.each do |fs|
        total = process_six_year_total(record["#{fs}_list"]) if record["#{fs}_list"].present?
        symbol = "#{fs}_six_year_total".to_sym
        totals_hash[symbol] = total
      end

      other_funding_sources = %w(public private ea)

      combined_total = 0
      other_funding_sources.each do |ofs|
        if record["#{ofs}_list"].present?
          total = process_six_year_total(record["#{ofs}_list"])
          combined_total += total.to_i
        end
      end
      combined_total = nil if combined_total.zero?
      totals_hash[:contributions_six_year_total] = combined_total

      totals_hash
    end

    def process_households_six_year_totals(record)
      keys = %w(
        flood_households
        coastal_households
      )

      total = 0

      keys.each do |key|
        total += process_six_year_total(record[key]) if record[key].present?
      end

      total = nil if total.zero?
      total
    end

    def process_six_year_total(array)
      array = JSON.parse(array)
      total = 0
      array.each { |e| total += e["f2"].to_i if e["f1"].to_i < 2021 }
      total
    end

    def year_by_year_breakdowns(record)
      breakdowns = {}
      funding_sources = %w(gia levy idb public private ea growth nyi total)

      funding_sources.each do |fs|
        if record["#{fs}_list"].present?
          breakdown = year_by_year_breakdown(record["#{fs}_list"], fs)
          breakdowns.merge!(breakdown)
        end
      end

      breakdowns
    end

    def households_year_by_year_breakdowns(record)
      keys = %w(
        flood_households
        flood_households_moved
        flood_most_deprived
        coastal_households
        coastal_households_protected
        coastal_most_deprived
      )

      breakdowns = {}

      keys.each do |key|
        households = record.fetch(key)
        households = "[{\"f1\": -1, \"f2\": 0 }]" if households.nil?
        breakdown = year_by_year_breakdown(households, key)
        breakdowns.merge!(breakdown)
      end

      breakdowns
    end

    def year_by_year_breakdown(array, type)
      breakdown = {}
      array = JSON.parse(array)
      previous_years = array.select { |e| e["f1"] == -1 }
      breakdown["#{type}_previous_years".to_sym] = previous_years.first["f2"]

      (2015..2027).each do |year|
        sym = "#{type}_#{year}".to_sym
        breakdown[sym] = nil
        year_amount = array.select { |e| e["f1"].to_i == year }
        breakdown[sym] = year_amount.first["f2"] if !year_amount.empty?
      end

      breakdown
    end

    def process_future_funding_totals(record)
      funding_sources = %w(gia total)

      totals = {}

      funding_sources.each do |fs|
        if record["#{fs}_list"].present?
          total = process_future_totals(record["#{fs}_list"])
          symbol = "#{fs}_future_total".to_sym
          totals[symbol] = total
        end
      end

      other_funding_sources = %w(public private ea)

      combined_total = 0
      other_funding_sources.each do |ofs|
        if record["#{ofs}_list"].present?
          total = process_future_totals(record["#{ofs}_list"])
          combined_total += total.to_i
        end
      end
      combined_total = nil if combined_total.zero?
      totals[:future_contributions_total] = combined_total

      totals
    end

    def process_future_household_totals(record)
      keys = %w(flood_households coastal_households)

      total = 0

      keys.each do |key|
        total += process_future_totals(record[key]).to_i if record[key].present?
      end

      total = nil if total.zero?
      { future_households_total: total }
    end

    def process_future_totals(array)
      breakdown = {}
      array = JSON.parse(array)

      total = 0
      (NEXT_FINANCIAL_YEAR..2021).each do |year|
        year_amount = array.select { |e| e["f1"].to_i == year }
        total += year_amount.first["f2"].to_i if !year_amount.empty?
      end

      total = nil if total.zero?
    end

    def process_dates(record)
      key_dates = %w(
        earliest_start
        start_outline_business_case
        award_contract
        start_construction
        ready_for_service
      )
      dates = {}

      key_dates.each do |key_date|
        month = record["#{key_date}_month"].to_i
        year = record["#{key_date}_year"].to_i

        date = nil
        date = Date.new(year, month) if month != 0 && year != 0
        dates[key_date.to_sym] = date
      end

      dates
    end

    def column_order
      PafsCore::SPREADSHEET_COLUMN_ORDER
    end

    def column_headers
      headers = []
      column_order.each do |column|
        header = PafsCore::SPREADSHEET_COLUMN_HEADERS.fetch(column, "~#{column} missing ~")
        headers << header
      end

      headers
    end

    def create_csv(records)
      CSV.generate do |csv|
        csv << column_headers
        records.each do |record|
          row = []
          column_order.each do |column|
            row << record.fetch(column, nil)
          end
          csv << row
        end
      end
    end

    def create_xlsx(records)
      xl = Axlsx::Package.new

      xl.workbook do |wb|
        wb.add_worksheet do |ws|
          ws.add_row(column_headers)
          records.each do |record|
            row = []
            column_order.each do |column|
              row << record.fetch(column, nil)
            end

            ws.add_row(row)
          end
        end
      end

      xl
    end
  end
end
