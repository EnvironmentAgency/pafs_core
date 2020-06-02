# frozen_string_literal: true

module PafsCore
  class AreaDownloadService
    include PafsCore::FileStorage
    include PafsCore::Files

    attr_reader :user

    def initialize(user)
      # when instantiated from a controller the 'current_user' should
      # be passed in. This will allow us to audit actions etc. down the line.
      @user = user
    end

    def generate_downloads
      return unless can_generate_documentation?

      info = download_info

      # update the info
      info.user = user
      info.area = area
      info.requested_on = Time.zone.now
      info.documentation_state.generate!
      info.save!

      # kick off background job
      PafsCore::GenerateAreaProgrammeJob.perform_later user.id
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
      PafsCore::Download::Area.perform(user)

      # send notification email to requestor
      PafsCore::AptNotificationMailer.area_programme_generation_complete(download_info).deliver_now
    rescue StandardError => e
      # send failure notification email
      PafsCore::AptNotificationMailer.area_programme_generation_failed(download_info).deliver_now
      Airbrake.notify(e) if defined? Airbrake
      raise e
    end

    def fcerm1_url
      expiring_url_for(apt_fcerm1_storage_filename(area), apt_fcerm1_filename)
    end

    def funding_calculators_url
      expiring_url_for(apt_pf_calculator_filename(area), apt_funding_calculator_filename)
    end

    def benefit_areas_url
      expiring_url_for(apt_benefit_areas_storage_filename(area), apt_benefit_areas_filename)
    end

    def moderations_url
      expiring_url_for(apt_moderation_storage_filename(area), apt_moderation_filename)
    end

    private

    def navigator
      @navigator ||= PafsCore::ProjectNavigator.new user
    end

    def area
      # TODO: this will need to change one day when multi-area users are enabled
      user.primary_area
    end
  end
end
