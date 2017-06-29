# frozen_string_literal: true
module PafsCore
  class AccountRequestCleanupJob < ActiveJob::Base
    queue_as :default

    def perform
      ActiveRecord::Base.connection_pool.with_connection do
        # remove account requests older than 30 days
        PafsCore::AccountRequest.expired.each(&:destroy)
        # remove User accounts which were invited 30 days ago or more
        # and the invite has not yet been accepted
        User.expired_invite.each(&:destroy)
      end
    end
  end
end
