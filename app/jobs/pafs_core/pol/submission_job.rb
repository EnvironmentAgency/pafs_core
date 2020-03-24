# frozen_string_literal: true

module PafsCore
  module Pol
    class SubmissionJob < ApplicationJob
      def perform(project_id)
        ApplicationRecord.connection_pool.with_connection do
          PafsCore::Pol::Submission.perform(PafsCore::Project.find(project_id))
        end
      end
    end
  end
end
