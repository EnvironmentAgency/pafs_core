# frozen_string_literal: true

module PafsCore
  class GenerateAreaProgrammeJob < ApplicationJob
    include PafsCore::FileStorage
    include PafsCore::Files

    def perform(user_id)
      ApplicationRecord.connection_pool.with_connection do
        user = PafsCore::User.find(user_id)
        PafsCore::AreaDownloadService.new(user).generate_area_programme
      end
    end
  end
end
