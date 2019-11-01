# frozen_string_literal: true

module PafsCore
  module Pol
    class ArchiveJob < ActiveJob::Base
      queue_as :default

      def perform(project_id)
        ActiveRecord::Base.connection_pool.with_connection do
          PafsCore::Pol::Archive.perform(PafsCore::Project.find(project_id))
        end
      end
    end
  end
end

