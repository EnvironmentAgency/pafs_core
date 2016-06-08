# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class User < ActiveRecord::Base
    # self.table_name = "users"
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates_uniqueness_of :email, case_sensitive: false

    has_many :user_areas
    has_many :areas, through: :user_areas

    def full_name
      "#{first_name} #{last_name}"
    end

    def primary_area
      #user_areas.includes(:area).find_by(primary: true).area
      user_areas.primary_area.first.area
    end

    def update_primary_area(area)
      user_areas.where(primary: true).update_all(primary: false)
      user_areas.find_by(area: area).update(primary: true)
    end
  end
end
