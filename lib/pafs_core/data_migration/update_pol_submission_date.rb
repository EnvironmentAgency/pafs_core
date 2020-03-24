# frozen_string_literal: true

module PafsCore
  module DataMigration
    class UpdatePolSubmissionDate
      def self.perform
        new.tap(&:perform)
      end

      def ids
        @ids ||= File.readlines(File.join(Rails.root, 'ids.txt'))
      end

      def date
        @date ||= Date.parse(ENV.fetch('SUBMISSION_DATE'))
      end

      def perform
        PafsCore::Project.where(reference_number: ids).update_all(submitted_to_pol: date)
      end
    end
  end
end
