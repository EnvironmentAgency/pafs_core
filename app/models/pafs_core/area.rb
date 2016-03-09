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

    belongs_to :parent, class_name: "Area"
    has_many :children, class_name: "Area", foreign_key: "parent_id"

    def parentage
      if area_type != AREA_TYPES[0] && parent_id.blank?
        errors.add(:parent_id, "can't be blank")
      elsif area_type == AREA_TYPES[0] && parent_id.present?
        errors.add(:parent_id, "must be blank")
      end
    end
  end
end
