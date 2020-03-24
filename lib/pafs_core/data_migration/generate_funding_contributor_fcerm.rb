# frozen_string_literal: true

module PafsCore
  module DataMigration
    class GenerateFundingContributorFcerm
      include PafsCore::FileStorage
      include PafsCore::Files

      def self.perform(user)
        new(user).perform
      end

      attr_reader :user

      def initialize(user)
        @user = user
      end

      def perform
        PafsCore::AreaDownload.transaction do
          download_info.save!
          puts ">> ---- generate_multi_fcerm1"
          generate_multi_fcerm1(projects, download_info.fcerm1_filename)
          puts "<< ---- generate_multi_fcerm1"
          download_info.documentation_state.complete!
          download_info.save!
        end
      end

      def area
        user.primary_area
      end

      def download_info
        @download_info ||= (area.area_download || area.create_area_download).tap do |dl|
          dl.number_of_proposals = projects.count
          dl.fcerm1_filename = apt_fcerm1_storage_filename(area)
          dl.user = user
          dl.requested_on = Time.zone.now
          dl.documentation_state.generate!
        end
      end

      def projects
        @projects ||= PafsCore::Project.where(
          "private_contributions = true OR public_contributions = true or other_ea_contributions = true"
        )
      end
    end
  end
end
