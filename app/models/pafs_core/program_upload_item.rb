# frozen_string_literal: true
module PafsCore
  class ProgramUploadItem < ApplicationRecord
    belongs_to :program_upload, inverse_of: :program_upload_items
    has_many :program_upload_failures, inverse_of: :program_upload_item,
      dependent: :destroy

    validates :reference_number, presence: true
  end
end
