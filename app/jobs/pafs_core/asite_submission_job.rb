# frozen_string_literal: true

module PafsCore
  class AsiteSubmissionJob < ApplicationJob
    def perform(project_id)
      ApplicationRecord.connection_pool.with_connection do
        PafsCore::AsiteService.new.submit_project(PafsCore::Project.find(project_id))
      end
    end
  end
end
