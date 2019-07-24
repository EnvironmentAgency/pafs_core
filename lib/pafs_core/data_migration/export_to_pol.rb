# frozen_string_literal: true

module PafsCore
  module DataMigration
    class ExportToPol
      def self.perform
        new.tap(&:perform)
      end

      def projects
        PafsCore::Project.submitted
      end

      def perform
        projects.find_each do |project|
          submission = PafsCore::Pol::Submission.new(project)
          submission.perform

          if submission.success?
            puts "[OK] #{project.reference_number}"
          else
            puts "[ERROR] #{project.reference_number}"
            puts submission.status
            puts submission.response
            puts "-------\n"
          end
        end
      end
    end
  end
end
