# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class UserArea < ActiveRecord::Base
    belongs_to :user
    belongs_to :area

    validate :area_is_set
    validates_uniqueness_of :user_id, scope: :area_id

    def self.primary_area
      self.includes(:area).where(primary: true)
    end

  private
    def area_is_set
      # we're ignoring the user_id as that should be set when contructing
      # the user_area, it's the area that the user will be selecting.
      # Also if we validate both we'll get error messages for both when no
      # area is selected which the user cannot do anything about from the front-end
      errors.add(:area_id, "^Select an area") if area_id.nil?
    end
  end
end
