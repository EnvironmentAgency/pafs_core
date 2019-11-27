# frozen_string_literal: true

require 'csv'

module PafsCore
  module DataMigration
    class UpdateProjects
      attr_reader :csv_path

      def self.perform(csv_path)
        new(csv_path).tap(&:perform)
      end

      def initialize(csv_path)
        @csv_path = csv_path
      end

      def perform
        CSV.foreach(csv_path, headers: true) do |row|
          project = PafsCore::Project.find_by(reference_number: row['PID'])
          area = PafsCore::Area.find_by(name: row['AREA'])

          if project.nil?
            puts "could not find #{row['PID']}"
            next
          end

          if area.nil?
            puts "could not find #{row['AREA']}"
            next
          end

          puts "[#{project.reference_number}] => #{area.name}"
          PafsCore::AreaProject.where(project_id: project.id).update_all(area_id: area.id)
        end
      end
    end
  end
end
