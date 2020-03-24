# frozen_string_literal: true
require "bstard"

module PafsCore
  class ProgramUpload < ApplicationRecord
    include PafsCore::FileTypes
    has_many :program_upload_items, inverse_of: :program_upload, dependent: :destroy
    has_many :program_upload_failures, through: :program_upload_items

    validate :file_selected
    validates :number_of_records, numericality: { only_integer: true }
    validates :status, inclusion: { in: %w[ new uploaded processing completed failed ] }

    # rubocop:disable Style/HashSyntax
    def processing_state
      machine = Bstard.define do |fsm|
        fsm.initial status
        fsm.event :upload, :new => :uploaded
        fsm.event :process, :uploaded => :processing
        fsm.event :complete, :processing => :completed
        fsm.event :error, :processing => :failed, :new => :failed
        fsm.when :any do |_event, _prev_state, new_state|
          update_attribute(:status, new_state)
        end
      end
    end
    # rubocop:enable Style/HashSyntax

    def finished_processing?
      state = processing_state
      state.completed? || state.failed?
    end

  private
    def file_selected
      errors.add(:base, "^Select the completed FCERM program (.xlsx) file") if filename.blank?
    end
  end
end
