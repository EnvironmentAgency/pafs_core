# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

require "bstard"

module PafsCore
  class AreaDownload < ApplicationRecord
    belongs_to :area, inverse_of: :area_download, optional: true
    belongs_to :user, inverse_of: :area_downloads, optional: true

    # rubocop:disable Style/HashSyntax
    def documentation_state
      machine = Bstard.define do |fsm|
        fsm.initial current_status
        fsm.event :generate, :empty => :generating, :ready => :generating, :failed => :generating
        fsm.event :complete, :generating => :ready
        fsm.event :error, :generating => :failed
        fsm.when :any do |_event, _prev_state, new_state|
          self.status = new_state
          save!
        end
      end
    end
    # rubocop:enable Style/HashSyntax

    def current_status
      status || :empty
    end
  end
end
