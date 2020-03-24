# frozen_string_literal: true
module PafsCore
  class GenerateAreaProgrammeJob < ApplicationJob
    include PafsCore::Files, PafsCore::FileStorage

    def perform(user_id)
      ApplicationRecord.connection_pool.with_connection do
        PafsCore::AreaDownloadService.new(PafsCore::User.find(user_id)).generate_area_programme
      end
    end
  end
end
