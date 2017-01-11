# frozen_string_literal: true
module PafsCore
  class AsiteFile < ActiveRecord::Base
    belongs_to :asite_submission, inverse_of: :asite_files
    validates :filename, :checksum, presence: true
  end
end
