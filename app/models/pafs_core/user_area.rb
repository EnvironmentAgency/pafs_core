# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class UserArea < ActiveRecord::Base
    belongs_to :user
    belongs_to :area

    validates_presence_of :user_id, :area_id
    validates_uniqueness_of :user_id, scope: :area_id

    def self.primary_area
      self.includes(:area).where(primary: true)
    end
  end
end
