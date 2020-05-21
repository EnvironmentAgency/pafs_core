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

      def self.fetch_all_fcrm1
        fetch_file(FILENAME) do |data, _filename|
          raise "Expected block to be passed to #fetch_all_fcrm1" unless block_given?

          yield data, filename
        end
      end

      def projects
        @projects ||= PafsCore::Project.joins(
          :areas,
          :coastal_erosion_protection_outcomes,
          :flood_protection_outcomes,
          :funding_values,
          :funding_contributors
        ).limit(30)
      end

      def update_status(data)
        meta.create({ last_update: Time.now.utc }.merge(data))
      end

      def meta
        @meta ||= PafsCore::Download::Meta.load("#{FILENAME}.meta")
      end

      def perform
        update_status(status: "pending", current_record: 1, total_records: projects.size)

        generate_multi_fcerm1(projects, FILENAME) do |total_records, current_record_index|
          if true || (current_record_index % 10) == 0
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
