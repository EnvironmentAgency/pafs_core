# frozen_string_literal: true
module PafsCore
  class GenerateAreaProgrammeJob < ActiveJob::Base
    queue_as :default

    include PafsCore::Files, PafsCore::FileStorage

    def perform(user_id)
      ActiveRecord::Base.connection_pool.with_connection do
        PafsCore::AreaDownloadService.new(PafsCore::User.find(user_id)).generate_area_programme
      end
    end
  end
end
