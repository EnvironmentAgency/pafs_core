# frozen_string_literal: true
module PafsCore
  class AsiteSubmissionJob < ActiveJob::Base
    queue_as :default

    def perform(project_id)
      ActiveRecord::Base.connection_pool.with_connection do
        PafsCore::AsiteService.new.submit_project(PafsCore::Project.find(project_id))
      end
    end
  end
end
