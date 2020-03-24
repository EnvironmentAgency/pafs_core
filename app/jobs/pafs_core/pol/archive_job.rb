# frozen_string_literal: true

module PafsCore
  module Pol
    class ArchiveJob < ApplicationJob
      def perform(project_id)
        ApplicationRecord.connection_pool.with_connection do
          PafsCore::Pol::Archive.perform(PafsCore::Project.find(project_id))
        end
      end
    end
  end
end
