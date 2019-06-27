# frozen_string_literal: true

module PafsCore
  module DataMigration
    class MoveFundingSources
      CONTRIBUTOR_ATTRIBUTES_MAP = {
        public_contributions: :public_contributor,
        private_contributions: :private_contributor,
        other_ea_contributions: :other_ea_contributor
      }.freeze

      def self.perform_all
        PafsCore::Project.find_each do |project|
          new(project).perform
          puts project.reference_number
        end
      end

      attr_reader :project

      def initialize(project)
        @project = project
      end

      def migrate_funding_source(funding_value, funding_source)
        funding_value.public_send(funding_source).find_or_create_by!(
          name: project.read_attribute("#{CONTRIBUTOR_ATTRIBUTES_MAP[funding_source]}_names"),
          amount: funding_value.read_attribute(funding_source),
          secured: false,
          constrained: false
        )
      end

      def perform
        PafsCore::FundingSources::AGGREGATE_SOURCES.each do |funding_source|
          next unless project.public_send("#{funding_source}?")

          project.funding_values.each do |funding_value|
            migrate_funding_source(funding_value, funding_source)
          end
        end
      end
    end
  end
end

