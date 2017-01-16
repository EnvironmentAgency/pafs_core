# frozen_string_literal: true
module PafsCore
  class AsiteSubmission < ActiveRecord::Base
    belongs_to :project, inverse_of: :asite_submissions
    has_many :asite_files, inverse_of: :asite_submission
    validates :email_sent_at, presence: true
    validates :status, presence: true

    def self.sent
      where(status: "sent")
    end

    # rubocop:disable Style/HashSyntax
    def submission_state
      machine = Bstard.define do |fsm|
        fsm.initial status
        fsm.event :deliver, :created => :sent
        fsm.event :confirm, :sent => :succeeeded
        fsm.event :reject, :sent => :failed
        fsm.when :any do |_event, _prev, new_state|
          self.status = new_state
          save!
        end
      end
    end
    # rubocop:enable Style/HashSyntax
  end
end
