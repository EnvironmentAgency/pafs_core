# frozen_string_literal: true

require "csv"

module PafsCore
  module DataMigration
    class UpdateAreas
      attr_reader :csv_path

      def self.perform(csv_path)
        new(csv_path).tap(&:perform)
      end

      def initialize(csv_path)
        @csv_path = csv_path
      end

      def perform
        not_found = []

        CSV.foreach(csv_path, headers: true) do |row|
          begin
            next if row["PAFS_LRMA_NAME"] == row["POL_LRMA_NAME"]

            area = PafsCore::Area.find_by(name: row["PAFS_LRMA_NAME"])
            destination_area = PafsCore::Area.where.not(
              id: (area ? area.id : nil)
            ).find_by(name: row["POL_LRMA_NAME"])

            next if destination_area && area.nil?

            if area.nil?
              not_found << row
              next
            end

            if destination_area
              puts "MERGE  [#{area.id} #{destination_area.id}] #{area.name} => #{row['POL_LRMA_NAME']}"
              PafsCore::AreaProject.where(area_id: area.id).update_all(area_id: destination_area.id)
              PafsCore::UserArea.where(area_id: area.id).update_all(area_id: destination_area.id)
              area.destroy
            else
              puts "RENAME [#{area.id}] #{area.name} => #{row['POL_LRMA_NAME']}"
              area.update_column(:name, row["POL_LRMA_NAME"])
            end
          end
        end

        if not_found.any?
          puts "Unable to update #{not_found.size} rows"
          puts
          puts not_found.to_yaml
        end
      end
    end
  end
end
