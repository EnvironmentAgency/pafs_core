# frozen_string_literal: true
module PafsCore
  class AsiteSubmission < ActiveRecord::Base
    belongs_to :project, inverse_of: :asite_submissions
    has_many :asite_files, inverse_of: :asite_submission
    validates :email_sent_at, presence: true
  end
end
