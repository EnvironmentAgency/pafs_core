# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class Area < ActiveRecord::Base
    AREA_TYPES = ["Country",
                  "EA Area",
                  "PSO Area",
                  "RMA"].freeze

    validates_presence_of :name, :area_type
    validates_uniqueness_of :name
    validate :parentage
    validates_inclusion_of :area_type, in: AREA_TYPES

    belongs_to :parent, class_name: "Area"
    has_many :children, class_name: "Area", foreign_key: "parent_id"
    has_many :area_projects

    scope :top_level, -> { where(parent_id: nil) }

    def parentage
      if area_type != AREA_TYPES[0] && parent_id.blank?
        errors.add(:parent_id, "can't be blank")
      elsif area_type == AREA_TYPES[0] && parent_id.present?
        errors.add(:parent_id, "must be blank")
      end
    end

    def owned_projects
      area_projects.ownerships.map(&:project)
    end

    def projects
      PafsCore::ProjectService.new.show_projects(self.id, self.area_type)
    end
  end
end
