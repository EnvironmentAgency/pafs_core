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
    validates :sub_type, presence: true, if: :rma?

    belongs_to :parent, class_name: "Area"
    has_many :children, class_name: "Area", foreign_key: "parent_id"
    has_many :area_projects
    has_many :projects, through: :area_projects

    scope :top_level, -> { where(parent_id: nil) }

    def self.ea_areas
      where(area_type: AREA_TYPES[1])
    end

    def self.pso_areas
      where(area_type: AREA_TYPES[2])
    end

    def self.rma_areas
      where(area_type: AREA_TYPES[3])
    end

    def country?
      area_type == AREA_TYPES[0]
    end

    def ea_area?
      area_type == AREA_TYPES[1]
    end

    def pso_area?
      area_type == AREA_TYPES[2]
    end

    def rma?
      area_type == AREA_TYPES[3]
    end

    def parentage
      if !country? && parent_id.blank?
        errors.add(:parent_id, "can't be blank")
      elsif country? && parent_id.present?
        errors.add(:parent_id, "must be blank")
      end
    end
  end
end
