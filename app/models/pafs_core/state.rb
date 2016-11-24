# frozen_string_literal: true
module PafsCore
  class State < ActiveRecord::Base
    belongs_to :project
    validates :state, inclusion: { in: %w[draft completed submitted] }
  end
end
