# frozen_string_literal: true
module PafsCore
  class ProjectsDownloadPresenter
    attr_reader :number_of_available_proposals, :download_info

    delegate :documentation_state, to: :download_info

    def initialize(download_info, number_of_available_proposals)
      @download_info = download_info
      @number_of_available_proposals = number_of_available_proposals
    end

    def requested_by
      download_info.user
    end

    def requested_on
      if download_info.requested_on
        download_info.requested_on.localtime.strftime "%d/%m/%Y at %H:%M"
      else
        "Unknown"
      end
    end

    def number_of_proposals_generated
      download_info.number_of_proposals || 0
    end

    def count
      number_of_available_proposals
    end

    def shapefile_count
      number_of_available_proposals
    end

    def moderation_count
      download_info.number_of_proposals_with_moderation || 0
    end

  private
    def calc_urgency_count
      projects.where.not(urgency_reason: "not_urgent").count
    end
  end
end
