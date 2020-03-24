# frozen_string_literal: true

module PafsCore
  module DataMigration
    class ExportToPol
      def self.perform
        new.tap(&:perform)
      end

      attr_reader :results

      def initialize
        @results = []
      end

      def ids
        @ids ||= File.readlines(File.join(Rails.root, "ids.txt"))
      end

      def projects
        @projects ||= PafsCore::Project.where(reference_number: ids)
      end

      def perform
        projects.find_each do |project|
          begin
            submission = PafsCore::Pol::Submission.new(project)
            submission.perform

            results << {
              id: project.reference_number,
              status: submission.status,
              response: submission.response
            }

            if submission.success?
              puts "[OK] #{project.reference_number}"
            else
              puts "[ERROR] #{project.reference_number}"
            end
          rescue StandardError => e
            puts "[ERROR] #{project.reference_number}"
            results << {
              id: project.reference_number,
              exception: e
            }
          end
        end

        File.open(File.join(Rails.root, "results.txt"), "w").write(results.inspect)
        puts results.inspect
      end
    end
  end
end
