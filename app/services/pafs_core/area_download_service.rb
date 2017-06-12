# frozen_string_literal: true

module PafsCore
  class AreaDownloadService
    include PafsCore::Files, PafsCore::FileStorage

    attr_reader :user

    def initialize(user)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def generate_downloads
      if can_generate_documentation?
        info = download_info

        #update the info
        info.user = user
        info.area = area
        info.requested_on = Time.zone.now
        info.documentation_state.generate!
        info.save!

        # kick off background job
        PafsCore::GenerateAreaProgrammeJob.perform_later user
      end
    end

    def download_info
      if area.area_download
        area.area_download.reload
      else
        area.create_area_download
      end
    end

    def can_generate_documentation?
      ds = download_info.documentation_state
      ds.empty? || ds.ready? || ds.failed?
    end

    # NOTE: Call me from a Job as I take a long time to complete
    def generate_area_programme
      begin
        navigator = PafsCore::ProjectNavigator.new user
        projects = navigator.find_apt_projects
        area = user.primary_area
        download_info = area.area_download

        # Generate FCERM1 with all submitted areas for the given user
        download_info.number_of_proposals = projects.count
        download_info.fcerm1_filename = apt_fcerm1_storage_filename(area)
        generate_multi_fcerm1(projects, download_info.fcerm1_filename)

        # Generate benefit areas archive
        download_info.benefit_areas_filename = apt_benefit_areas_storage_filename(area)
        generate_benefit_areas_file(projects, download_info.benefit_areas_filename)

        # Generate moderation archive (only for urgent projects)
        download_info.number_of_proposals_with_moderation = calc_moderation_count(projects)

        if download_info.number_of_proposals_with_moderation.positive?
          download_info.moderation_filename = apt_moderation_storage_filename(area)
          generate_moderations_file(projects, download_info.moderation_filename)
        else
          download_info.moderation_filename = nil
        end

        download_info.documentation_state.complete!
        download_info.save!
      rescue => e
        download_info.documentation_state.error!
        # send failure notification email
        PafsCore::AptNotificationMailer.area_programme_generation_failed(download_info).deliver_now
        Airbrake.notify(e) if defined? Airbrake
        raise e
      end

      # send notification email to requestor
      PafsCore::AptNotificationMailer.area_programme_generation_complete(download_info).deliver_now
    end

    def fetch_fcerm1
      fetch_file(apt_fcerm1_storage_filename(area)) do |file_data, _filename|
        if block_given?
          yield file_data, apt_fcerm1_filename
        else
          raise "Expecting block for apt fcerm1 download"
        end
      end
    end

    def fetch_benefit_areas
      fetch_file(apt_benefit_areas_storage_filename(area)) do |file_data, _filename|
        if block_given?
          yield file_data, "application/zip", apt_benefit_areas_filename
        else
          raise "Expecting block for apt benefit areas download"
        end
      end
    end

    def fetch_moderations
      fetch_file(apt_moderation_storage_filename(area)) do |file_data, _filename|
        if block_given?
          yield file_data, "application/zip", apt_moderation_filename
        else
          raise "Expecting block for apt moderation download"
        end
      end
    end

  private
    def navigator
      @navigator ||= PafsCore::ProjectNavigator.new user
    end

    def area
      # TODO: this will need to change one day when multi-area users are enabled
      user.primary_area
    end

    def calc_moderation_count(projects)
      projects.where.not(urgency_reason: "not_urgent").count
    end
  end
end
