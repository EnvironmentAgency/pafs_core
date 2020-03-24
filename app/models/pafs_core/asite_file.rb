# frozen_string_literal: true

module PafsCore
  class AsiteFile < ApplicationRecord
    belongs_to :asite_submission, inverse_of: :asite_files
    validates :filename, :checksum, presence: true
  end
end
