# frozen_string_literal: true
module PafsCore
  class ImportProgramRefreshJob < ActiveJob::Base
    queue_as :default

    def perform(upload_record)
      pup = PafsCore::ProgramUploadService.new
      pup.process_spreadsheet(upload_record)
    end
  end
end
