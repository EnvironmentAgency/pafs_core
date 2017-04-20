# frozen_string_literal: true
module PafsCore
  class State < ActiveRecord::Base
    belongs_to :project, inverse_of: :state
    validates :state, inclusion: { in: %w[draft completed submitted updatable updated finished] }

    def self.submitted
      where(state: "submitted")
    end

    def self.refreshable
      # states that can be "opened" during programme refresh
      where(state: %w[completed submitted updated finished])
    end
  end
end
