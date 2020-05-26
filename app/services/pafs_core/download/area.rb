# frozen_string_literal: true

module PafsCore
  module Download
    class Area < Base
      attr_reader :user

      def initialize(requesting_user:)
        @user = requesting_user
      end

      def navigator
        @navigator ||= PafsCore::ProjectNavigator.new user
      end

      def projects
        @projects ||= navigator.find_apt_projects
      end

      def area
        @area ||= user.primary_area
      end

      def download_info
        area.area_download
      end

      def create_fcrm1
        download_info.number_of_proposals = projects.count
        download_info.fcerm1_filename = apt_fcerm1_storage_filename(area)
        generate_multi_fcerm1(projects, download_info.fcerm1_filename)
      end

      def create_benefit_areas
        download_info.benefit_areas_filename = apt_benefit_areas_storage_filename(area)
        generate_benefit_areas_file(projects, download_info.benefit_areas_filename)
      end

      def create_proposals_funding_calc
        download_info.funding_calculator_filename = apt_pf_calculator_filename(area)
        generate_proposals_funding_calculator_file(projects, download_info.funding_calculator_filename)
      end

      def create_moderations
        download_info.number_of_proposals_with_moderation = calc_moderation_count(projects)

        if download_info.number_of_proposals_with_moderation.positive?
          download_info.moderation_filename = apt_moderation_storage_filename(area)
          generate_moderations_file(projects, download_info.moderation_filename)
        else
          download_info.moderation_filename = nil
        end
      end

      def perform
        # Generate FCERM1 with all submitted areas for the given user
        create_fcrm1

        # Generate benefit areas archive
        create_benefit_areas

        # Generate proposal funding calc file
        create_proposals_funding_calc

        # Generate moderation archive (only for urgent projects)
        create_moderations

        download_info.documentation_state.complete!
        download_info.save!
      rescue StandardError => e
        download_info.documentation_state.error!
        raise e
      end
    end
  end
end
