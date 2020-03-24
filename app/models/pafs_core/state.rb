# frozen_string_literal: true

module PafsCore
  class State < ApplicationRecord
    VALID_STATES = %w[draft completed submitted updatable updated archived finished].freeze

    belongs_to :project, inverse_of: :state, optional: true
    validates :state, inclusion: { in: VALID_STATES }

    def self.submitted
      where(state: "submitted")
    end

    def self.refreshable
      # states that can be "opened" during programme refresh
      where(state: %w[completed submitted updated finished])
    end
  end
end
