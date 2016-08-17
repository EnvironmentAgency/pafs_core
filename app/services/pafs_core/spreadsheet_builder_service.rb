# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class SpreadsheetBuilderService
    require "csv"

    NEXT_FINANCIAL_YEAR = 1.year.from_now.uk_financial_year

    def generate_csv(projects)
      records = get_records(projects)
      processed_records = process_records(records)
      create_csv(processed_records)
    end

    def get_records(projects)
      project_ids = projects.map(&:id)

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
      WHERE p.id IN (#{project_ids.join(',')})
      AND ap.owner = true"

      records_array = ActiveRecord::Base.connection.execute(sql).to_a
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
      processed_record[:rfcc] = rfcc_name(record["reference_number"])
      processed_record.merge!(add_lead_rma(record))
      processed_record.merge!(process_geo_data(record))
      processed_record.merge!(process_funding_totals(record))
      processed_record.merge!(process_households_totals(record))
      processed_record.merge!(process_funding_six_year_totals(record))
      processed_record.merge!(process_households_six_year_totals(record))
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
        urgency_reason
        flood_protection_before
        flood_protection_after
        coastal_protection_before
        coastal_protection_after
        main_risk region
        parliamentary_consituency
        improve_surface_or_groundwater
        improve_surface_or_groundwater_amount
        improve_river
        improve_spa_or_sac
        improve_sssi
        improve_hpi
        improve_habitat_amount
        improve_river_amount
        create_habitat
        create_habitat_amount
        remove_fish_barrier
        remove_eel_barrier
        fish_or_eel_amount
      )
      extracted_data = {}

      keys.each do |key|
        extracted_data[key.to_sym] = record[key]
      end

      extracted_data
    end

    def rfcc_name(project_number)
      rfcc_code = project_number[0, 2]
      PafsCore::RFCC_CODE_NAMES_MAP.fetch(rfcc_code)
    end

    def add_lead_rma(record)
      lead_rma = ""
      lead_rma_type = ""
      if record["area_type"] == "RMA"
        lead_rma = record["area_name"]
        lead_rma_type = record["area_sub_type"]
      end

      { lead_rma: lead_rma, lead_rma_type: lead_rma_type }
    end

    def process_geo_data(record)
      location = record["project_location"].scan(/\d+/).map(&:to_i)
      grid_ref = ""
      grid_ref = Cumberland.get_grid_reference_from_coordinates(location[0], location[1]) if location.size == 2
      ea_area = if record["parent_area_type"] == "EA Area"
                  record["parent_area_name"]
                else
                  record["grandparent_area_name"]
                end
      {grid_ref: grid_ref, ea_area: ea_area}
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
      total
    end

    def process_funding_six_year_totals(record)
      totals_hash = {}
      funding_sources = %w(gia levy idb public private ea growth nyi total)
      funding_sources.each do |fs|
        total = nil
        total = process_six_year_total(record["#{fs}_list"]) if record["#{fs}_list"].present?
        symbol = "#{fs}_six_year_total".to_sym
        totals_hash[symbol] = total
      end

      totals_hash
    end

    def process_households_six_year_totals(record)
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
        total = process_six_year_total(record[key]) if record[key].present?
        symbol = "#{key}_six_year_total".to_sym
        totals_hash[symbol] = total
      end

      totals_hash
    end

    def process_six_year_total(array)
      array = JSON.parse(array)
      total = 0
      array.each { |e| total += e["f2"].to_i if e["f1"].to_i < 2022 }
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
        if record[key].present?
          breakdown = year_by_year_breakdown(record[key], key)
          breakdowns.merge!(breakdown)
        end
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
        breakdown[sym] = 0
        year_amount = array.select { |e| e["f1"] == year }
        breakdown[sym] = year_amount.first["f2"] if !year_amount.empty?
      end

      breakdown
    end

    def process_future_funding_totals(record)
      funding_sources = %w(gia levy total)

      totals = {}

      funding_sources.each do |fs|
        if record["#{fs}_list"].present?
          total = process_future_totals(record["#{fs}_list"])
          symbol = "#{fs}_2017_2021_total".to_sym
          totals[symbol] = total
        end
      end

      other_funding_sources = %w(idb public private ea growth nyi)

      combined_total = 0
      other_funding_sources.each do |ofs|
        if record["#{ofs}_list"].present?
          total = process_future_totals(record["#{ofs}_list"])
          combined_total += total
        end
      end
      totals[:future_contributions_total] = combined_total

      totals
    end

    def process_future_household_totals(record)
      keys = %w(flood_households coastal_households)

      total = 0

      keys.each do |key|
        total += process_future_totals(record[key]) if record[key].present?
      end

      { future_households_total: total }
    end

    def process_future_totals(array)
      breakdown = {}
      array = JSON.parse(array)

      total = 0
      (NEXT_FINANCIAL_YEAR..2021).each do |year|
        year_amount = array.select { |e| e["f1"] == year }
        total += year_amount.first["f2"].to_i if !year_amount.empty?
      end

      total
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

    def create_csv(records)
      file_path = [Rails.root.to_s, "tmp"].join("/")

      CSV.open("#{file_path}/file.csv", "wb") do |csv|
        csv << records.first.keys
        records.each do |record|
          csv << record.values
        end
      end
    end
  end
end
