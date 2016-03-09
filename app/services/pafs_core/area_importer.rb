# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class AreaImporter

    require "csv"
    HEADERS = ["name",
               "parent area",
               "type"].freeze

    def initialize
      @areas = Array.new
      @faulty_entries = Array.new
    end

    def import
      CSV.foreach("#{Rails.root}/areas.csv", headers: true) do |row|
        @areas << row.to_h
      end

      abort("Headers incorrect.") unless @areas.first.keys == HEADERS

      areas = group_by_type(@areas)

      PafsCore::Area::AREA_TYPES.each { |area_type| create_records(areas[area_type]) }
      write_error_csv(@faulty_entries)
    end

    private

    def group_by_type(areas)
      areas.group_by { |area| area["type"] }
    end

    def create_records(areas)
      areas_grouped_by_parent = group_by_parent(areas)
      create_child_records(areas_grouped_by_parent)
    end

    def group_by_parent(areas)
      areas.group_by { |area| area["parent area"] }
    end

    def create_child_records(areas_grouped_by_parent)
      areas_grouped_by_parent.each do |parent, children|
        parent = Area.find_by_name(parent)

        area_records = Array.new
        children.each do |child|
          area = {
            name: child["name"],
            area_type: child["type"]
          }
          area[:parent_id] = parent.id if parent

          if parent || child["type"] == PafsCore::Area::AREA_TYPES[0]
            begin
              Area.create(area)
            rescue
              report_error(e, child)
            end
          else
            report_error("No matching parent area found", child)
          end
        end
      end
    end

    def write_error_csv(faulty_entries)
      CSV.open("#{Rails.root}/faulty-entries.csv", "wb") do |csv|
        csv << faulty_entries.first.keys
        faulty_entries.each do |faulty_entry|
          csv << faulty_entry.values
        end
      end
    end

    def report_error(error, record)
      record[:error] = error
      @faulty_entries << record
    end
  end
end
