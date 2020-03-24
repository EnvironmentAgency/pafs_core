# frozen_string_literal: true

module PafsCore
  class ImportProgramRefreshJob < ApplicationJob
    def perform(upload_record_id)
      ApplicationRecord.connection_pool.with_connection do
        pup = PafsCore::ProgramUploadService.new
        pup.process_spreadsheet(pup.find(upload_record_id))
      end
    end
  end
end
