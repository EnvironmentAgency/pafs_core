# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class AreaProject < ActiveRecord::Base
    belongs_to :project
    belongs_to :area

    scope :ownerships, -> { where(owner: true) }
  end
end
