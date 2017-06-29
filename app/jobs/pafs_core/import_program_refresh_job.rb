# frozen_string_literal: true
module PafsCore
  class ImportProgramRefreshJob < ActiveJob::Base
    queue_as :default

    def perform(upload_record_id)
      ActiveRecord::Base.connection_pool.with_connection do
        pup = PafsCore::ProgramUploadService.new
        pup.process_spreadsheet(pup.find(upload_record_id))
      end
    end
  end
end
