# frozen_string_literal: true

module PafsCore
  class User < ApplicationRecord
    validates :first_name, presence: true
    validates :last_name, presence: true
    # validates_uniqueness_of :email, case_sensitive: false

    has_many :user_areas
    has_many :areas, through: :user_areas

    has_many :projects, foreign_key: "creator_id"

    # possible if a user has many areas they could initiate downloads in more than
    # one area
    has_many :area_downloads, inverse_of: :user

    def self.expired_invite
      where(invitation_accepted_at: nil)
        .where(arel_table[:invitation_created_at].lt(30.days.ago))
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def rfcc_code(area_name = nil)
      area = nil
      area = if area_name
               PafsCore::Area.find_by_name(area_name)
             else
               # find the PSO area under which this user belongs
               primary_area
             end
      unless area.ea_area?
        area = area.parent if area.rma?
        PafsCore::PSO_RFCC_MAP.fetch(area.name)
      end
    end

    def primary_area
      user_areas.primary_area.first.area
    end

    def update_primary_area(area)
      user_areas.where(primary: true).update_all(primary: false)
      user_areas.find_by(area: area).update(primary: true)
    end
  end
end
