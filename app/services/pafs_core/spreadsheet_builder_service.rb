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
      processed_record.merge!(extract_straightforward_data(record))
      processed_record.merge!(process_pv_whole_life_figures(record))
      processed_record.merge!(process_flood_protection(record))
      processed_record.merge!(process_coastal_protection(record))
      processed_record[:rfcc] = rfcc_name(record["reference_number"])
      processed_record[:coastal_group] = add_coastal_group(record)
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
      processed_record.merge!(process_binary_values(record))
      processed_record.merge!(process_extraneous_columns)
    end

    def extract_straightforward_data(record)
      keys = %w(
        name
        reference_number
        project_type
        approach
        region
        county
        parliamentary_constituency
        improve_surface_or_groundwater_amount
        create_habitat
        public_contributor_names
        private_contributor_names
        other_ea_contributor_names
      )

      risk_urgency_keys = %w(urgency_reason main_risk)

      numerical_keys = %w(
        raw_partnership_funding_score
        adjusted_partnership_funding_score
        fish_or_eel_amount
        create_habitat_amount
        improve_river_amount
        improve_habitat_amount
        hectares_of_net_water_intertidal_habitat_created
        hectares_of_net_water_dependent_habitat_created
        kilometres_of_protected_river_improved
      )

      extracted_data = {}

      keys.each do |key|
        extracted_data[key.to_sym] = record[key]
      end

      risk_urgency_keys.each do |key|
        extracted_data[key.to_sym] = record[key].to_s.humanize
      end

      numerical_keys.each do |key|
        extracted_data[key.to_sym] = record[key].to_f
      end

      extracted_data[:duration_of_benefits] = record["duration_of_benefits"].to_i

      extracted_data
    end

    def process_pv_whole_life_figures(record)
      pv_whole_life_benefits = record["pv_whole_life_benefits"].to_f
      pv_whole_life_costs = record["pv_whole_life_costs"].to_f
      pv_whole_life_benefit_cost_ratio = pv_whole_life_benefits / pv_whole_life_costs

      {
        pv_whole_life_benefits: pv_whole_life_benefits,
        pv_whole_life_costs: pv_whole_life_costs,
        pv_whole_life_benefit_cost_ratio: pv_whole_life_benefit_cost_ratio
      }
    end

    def process_binary_values(record)
      binary_hash = {}
      binary_hash[:remove_fish_or_eel_barrier] = remove_fish_or_eel_barrier?(record)
      binary_hash[:improve_sac_or_sssi] = improve_sac_or_sssi?(record)
      binary_hash[:strategic_approach] = strategic_approach?(record)

      binary_hash
    end

    def remove_fish_or_eel_barrier?(record)
      process_binary_value(record["remove_eel_barrier"] == "t" || record["remove_fish_barrier"] == "t")
    end

    def improve_sac_or_sssi?(record)
      process_binary_value(record["improve_sssi"] == "t" || record["improve_spa_or_sac"] == "t")
    end

    def strategic_approach?(record)
      process_binary_value(record["strategic_approach"] == "t")
    end

    def process_binary_value(value)
      if value == true
        "Yes"
      else
        "No"
      end
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

    def outdated_columns
      PafsCore::SPREADSHEET_UNUSED_COLUMNS
    end

    def process_extraneous_columns
      extraneous_data = {}

      outdated_columns.each { |column| extraneous_data[column] = "xx" }

      extraneous_data
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
          %I(raw_partnership_funding_score adjusted_partnership_funding_score).each do |score|
            record[score] = record[score] * 100
          end
          row = []
          column_order.each do |column|
            row << record.fetch(column, nil)
          end
          csv << row
        end
      end
    end

    def project_years
      [
        "Pre Yr0",
        "Pre Yr0.1",
        "Pre Yr0.2",
        "Year 1",
        "Year 2",
        "Year 3",
        "Year 4",
        "Year 5",
        "Year 6",
        "Year 7",
        "Year 8",
        "Year 9",
        "Year 10",
        "Year 11 on"
      ].freeze
    end

    def blank_row
      row = {}
      ("A".."Z").to_a.each { |letter| row[letter.to_sym] = "" }
      ("A".."L").to_a.each do |alpha|
        ("A".."Z").to_a.each do |beta|
          key = (alpha + beta).to_sym
          row[key] = ""
        end
      end

      %I(LY LZ).each { |k| row.delete(k) }

      row
    end

    def default_styles(ws)
      style_row = blank_row

      style_row.each do |k, _v|
        style_row[k] = ws.styles.add_style(
          border: {
            style: :thin,
            color: "FFFFFFFF"
          },
          alignment: {
            wrap_text: true
          }
        )
      end

      style_row
    end

    def default_style_with_border(ws)
      style_row = blank_row

      style_row.each do |k, _v|
        style_row[k] = ws.styles.add_style(
          border: {
            style: :thin,
            color: "FF000000",
            alignment: {
              wrap_text: true
            }
          }
        )
      end

      style_row
    end

    def default_header_style(ws)
      style_row = blank_row

      style_row.each do |k, _v|
        style_row[k] = ws.styles.add_style(
          border: {
            style: :thin,
            color: "FF000000"
          },
          b: true,
          alignment: {
            horizontal: :center,
            vertical: :center,
            wrap_text: true
          }
        )
      end

      style_row
    end

    def first_row
      row = blank_row
      row[:A] = "FCRM1 - Medium Term Plan"

      row.values.to_a
    end

    def first_row_styles(ws)
      style_row = default_styles(ws)

      style_row[:A] = ws.styles.add_style(
        bg_color: "FF000000",
        fg_color: "00FFFFFF",
        sz: 20,
        b: true,
        alignment: {
          vertical: :center
        }
      )

      style_row.values.to_a
    end

    def second_row_custom_info
      PafsCore::SpreadsheetCustomStyles::SECOND_ROW
    end

    def second_row
      row = blank_row

      second_row_custom_info.each { |k, v| row[k] = v[:title] }

      row.values.to_a
    end

    def second_row_styles(ws)
      style_row = default_styles(ws)

      second_row_custom_info.each do |k, v|
        style_row[k] = ws.styles.add_style(
          bg_color: v[:bg_color],
          fg_color: "FF000000",
          sz: 20,
          b: true,
          alignment: {
            vertical: :center
          },
          border: {
            style: :thin,
            color: "66000000"
          }
        )
      end

      style_row.values.to_a
    end

    def third_row
      row = blank_row
      cells = %I(BH BV CJ CX DL DZ EN FB FP GD GR HF HT IH JJ JX KL)

      cells.each { |cell| row[cell] = "15/16 - 20/21 programme" }

      row.values.to_a
    end

    def third_row_styles(ws)
      style_row = default_styles(ws)
      cells = %I(BH BV CJ CX DL DZ EN FB FP GD GR HF HT IH JJ JX KL)
      border_cells = %I(BN CB CP DD DR EF ET FH FV GJ GY HL IA IN JP KD KR)

      cells.each do |cell|
        style_row[cell] = ws.styles.add_style(
          bg_color: "FFFFFF1A",
          border: {
            style: :thick,
            color: "66000000",
            edges: [:top, :left, :right]
          }
        )
      end

      border_cells.each do |cell|
        style_row[cell] = ws.styles.add_style(
          fg_color: "FFFFFFFF",
          border: {
            style: :thin,
            color: "66000000",
            edges: [:left]
          }
        )
      end

      style_row.values.to_a
    end

    def fourth_row
      row = blank_row

      fourth_row_custom.each { |k, v| row[k] = v[:title] }

      row.values.to_a
    end

    def fourth_row_custom
      PafsCore::SpreadsheetCustomStyles::FOURTH_ROW
    end

    def fourth_row_styles(ws)
      style_row = default_styles(ws)

      fourth_row_custom.each do |k, v|
        style_row[k] = ws.styles.add_style(
          bg_color: v[:bg_color],
          fg_color: "FF000000",
          b: true,
          sz: 10,
          alignment: {
            vertical: :center,
            horizontal: :center
          },
          border: {
            style: :thin,
            color: "FFFFFFFF"
          }
        )
      end

      style_row.values.to_a
    end

    def fifth_row
      row = []
      40.times { row << "" }
      18.times { row << "TOTAL" }
      18.times { row << project_years && row.flatten! }
      9.times { row << "" }
      row << "17/18-20/21"
      3.times { row << "" }
      row << "Rolling 6 year programme"

      row
    end

    def dark_yellow_cells
      %I(BJ BX CL CZ DN EB EP FD FR GF GT HH HV IJ IX JL JZ KN)
    end

    def light_yellow_cells
      %I(
        BK BL BM BN BO
        BY BZ CA CB CC
        CM CN CO CP CQ
        DA DB DC DD DE
        DO DP DQ DR DS
        EC ED EE EF EG
        EQ ER ES ET EU
        FE FF FG FH FI
        FS FT FU FV FW
        GG GH GI GJ GK
        GU GV GW GX GY
        HI HJ HK HL HM
        HW HX HY HZ IA
        IK IL IM IN IO
        IY IZ JA JB JC
        KA KB KC KD KE
        KO KP KQ KR KS
      )
    end

    def grey_cells
      %I(LH LL)
    end

    def fifth_row_styles(ws)
      style_row = default_style_with_border(ws)

      dark_yellow_cells.each do |cell|
        style_row[cell] = ws.styles.add_style(
          bg_color: "FFFFFF1A",
          border: {
            style: :thin,
            color: "66000000"
          }
        )
      end

      light_yellow_cells.each do |cell|
        style_row[cell] = ws.styles.add_style(
          bg_color: "FFFFFFB3",
          border: {
            style: :thin,
            color: "66000000"
          }
        )
      end

      grey_cells.each do |cell|
        style_row[cell] = ws.styles.add_style(
          bg_color: "AA404040",
          fg_color: "FF000000",
          sz: 20,
          b: true,
          alignment: {
            vertical: :center
          },
          border: {
            style: :thin,
            color: "66000000"
          }
        )
      end

      style_row.values.to_a
    end

    def column_header_styles(ws)
      style_row = default_header_style(ws)

      dark_yellow_cells.each do |cell|
        style_row[cell] = ws.styles.add_style(
          bg_color: "FFFFFF1A",
          border: {
            style: :thin,
            color: "66000000"
          },
          alignment: {
            horizontal: :center,
            vertical: :center,
            wrap_text: true
          },
          b: true
        )
      end

      light_yellow_cells.each do |cell|
        style_row[cell] = ws.styles.add_style(
          bg_color: "FFFFFFB3",
          border: {
            style: :thin,
            color: "66000000"
          },
          alignment: {
            horizontal: :center,
            vertical: :center,
            wrap_text: true
          },
          b: true
        )
      end

      style_row.values.to_a
    end

    def cells_to_be_merged
      %w(
        A3:AJ3 AK3:AN3 AO3:GB3 GC3:KX3 KY3:LG3 LH3:LO3 LP3:LU3
        A6:E7 F6:J7 K6:N7 O6:S7 T6:AA7 AB6:AH7 AI6:AJ7 AK6:AN7 AO6:BF6
        BG6:BT6 BU6:CH6 CI6:CV6 CW6:DJ6 DK6:DX6 DY6:EL6 EM6:EZ6 FA6:FN6
        FO6:GB6 GC6:GP6 GQ6:HD6 HE6:HR6 HS6:IF6 IG6:IT6 IU6:JH6 JI6:JV6
        JW6:KJ6 KK6:KX6 KY6:LG7 LH6:LO6 LP6:LU7
        BH5:BM5 BV5:CA5 CJ5:CO5 CX5:DC5 DL5:DQ5 DZ5:EE5 EN5:ES5
        FB5:FG5 FP5:FW5 GD5:GI5 GR5:GW5 HF5:HK5 HT5:HY5 IH5:IN5
        IV5:JA5 JJ5:JO5 JX5:KC5 KL5:KQ5
        LH7:LK7 LL7:LO7
      )
    end

    def create_xlsx(records)
      xl = Axlsx::Package.new

      xl.workbook do |wb|
        wb.date1904 = true
        wb.add_worksheet do |ws|
          ws.name = "FCRM1"
          ws.sheet_view.show_grid_lines = false
          ws.add_row(first_row, height: 30, style: first_row_styles(ws))
          ws.add_row(blank_row.values.to_a, height: 10, style: default_styles(ws).values.to_a)
          ws.add_row(second_row, height: 40, style: second_row_styles(ws))
          ws.add_row(blank_row.values.to_a, height: 10, style: default_styles(ws).values.to_a)
          ws.add_row(third_row, height: 30, style: third_row_styles(ws))
          ws.add_row(fourth_row, height: 80, style: fourth_row_styles(ws))
          ws.add_row(fifth_row, height: 30, style: fifth_row_styles(ws))

          default_cell_style = {border: { style: :thin, color: "66000000"}}
          standard_cell = ws.styles.add_style(default_cell_style)
          date_cell = ws.styles.add_style(default_cell_style.merge(format_code: "dd/mm/yyyy"))
          percentage_cell = ws.styles.add_style(default_cell_style.merge(num_fmt: Axlsx::NUM_FMT_PERCENT))

          ws.add_row(
            column_headers,
            height: 100,
            style: column_header_styles(ws),
            widths: [100, *([30] * 335)]
          )

          records.each do |record|
            row = []
            column_order.each do |column|
              row << record.fetch(column, nil)
            end

            ws.add_row(
              row,
              style: [
                *([standard_cell] * 28),
                *([percentage_cell] * 2),
                *([standard_cell] * 5),
                *([date_cell] * 5),
                *([standard_cell] * 296)
              ])
          end

          cells_to_be_merged.each { |set| ws.merge_cells(set) }
        end
      end

      xl
    end
  end
end
