# frozen_string_literal: true
module PafsCore
  class GenerateAreaProgrammeJob < ActiveJob::Base
    queue_as :default

    include PafsCore::Files, PafsCore::FileStorage

    def perform(user)
      PafsCore::AreaDownloadService.new(user).generate_area_programme
    end
  end
end
