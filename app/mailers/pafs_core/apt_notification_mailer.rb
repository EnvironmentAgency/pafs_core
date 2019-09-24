# frozen_string_literal: true
module PafsCore
  class AptNotificationMailer < ApplicationMailer
    include PafsCore::Email
    add_template_helper(PafsCore::EmailHelper)

    def area_programme_generation_complete(download_info)
      prevent_tracking
      @download_info = PafsCore::ProjectsDownloadPresenter.new(download_info, 0)

      return unless @download_info.requested_by

      mail(to: @download_info.requested_by.email, subject: "Area programme generation complete - FCERM project funding")
    end

    def area_programme_generation_failed(download_info)
      prevent_tracking
      @download_info = PafsCore::ProjectsDownloadPresenter.new(download_info, 0)

      return unless @download_info.requested_by

      mail(to: @download_info.requested_by.email, subject: "Area programme generation failed - FCERM project funding")
    end
  end
end
