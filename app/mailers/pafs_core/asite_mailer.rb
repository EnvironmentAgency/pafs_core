# frozen_string_literal: true
module PafsCore
  class AsiteMailer < ApplicationMailer
    include PafsCore::Files

    def submit_project(reference, files)
      files.each do |k, v|
        attachments[k] = v
      end

      mail(to: ENV.fetch("BACKUP_MAIL_RECIPIENT"),
           subject: reference)
    end
  end
end
