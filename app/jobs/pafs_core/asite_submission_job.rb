# frozen_string_literal: true
module PafsCore
  class AsiteSubmissionJob < ActiveJob::Base
    queue_as :default

    def perform(project)
      PafsCore::AsiteService.new.submit_project(project)
    end
  end
end
