# frozen_string_literal: true
module PafsCore
  class ProgramUploadFailure < ActiveRecord::Base
    belongs_to :program_upload_item, inverse_of: :program_upload_failures

    validates :field_name, presence: true
    validates :messages, presence: true
  end
end
