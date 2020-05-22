# frozen_string_literal: true

module PafsCore
  module Download
    class All < Base
      FILENAME = {
        production: "area_programme/all.xlsx",
        test: "area_programme/all-test.xlsx",
        development: "area_programme/all-dev.xlsx"
      }.fetch(Rails.env.to_sym)

      def self.exists?
        file_exists?(FILENAME)
      end

      def fetch_remote_file
        fetch_file(FILENAME) do |data|
          raise "Expected block to be passed to #fetch_remote_file" unless block_given?

          yield data
        end
      end

      def projects
        @projects ||= PafsCore::Project.includes(
          :areas,
          :coastal_erosion_protection_outcomes,
          :flood_protection_outcomes,
          :funding_values,
          :funding_contributors
        )
      end

      def update_status(data)
        meta.create({ last_update: Time.now.utc }.merge(data))
      end

      def meta
        @meta ||= PafsCore::Download::Meta.load("#{FILENAME}.meta")
      end

      def perform
        generate_multi_fcerm1(projects, FILENAME) do |total_records, current_record_index|
          if (current_record_index % 10).zero?
            update_status(status: "pending", current_record: current_record_index, total_records: total_records)
          end
        end

        update_status(status: "complete")
      rescue StandardError => e
        update_status(status: "failed", exception: e.inspect)
      end
    end
  end
end
