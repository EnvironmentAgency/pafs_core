# frozen_string_literal: true
module PafsCore
  class Area < ApplicationRecord
    AREA_TYPES = [
      COUNTRY_AREA = "Country",
      EA_AREA      = "EA Area",
      PSO_AREA     = "PSO Area",
      RMA_AREA     = "RMA"
    ].freeze

    validates_presence_of :name, :area_type
    validates_uniqueness_of :name
    validate :parentage
    validates_inclusion_of :area_type, in: AREA_TYPES
    validates :sub_type, presence: true, if: :rma?

    belongs_to :parent, class_name: "Area", optional: true
    has_many :children, class_name: "Area", foreign_key: "parent_id"
    has_many :area_projects
    has_many :projects, through: :area_projects
    has_one :area_download, inverse_of: :area

    scope :top_level, -> { where(parent_id: nil) }

    def self.country
      find_by(area_type: AREA_TYPES[0])
    end

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

    def ea_parent
      return self if ea_area?
      if ea_area?
        return self
      elsif pso_area?
        return parent
      elsif rma?
        return parent.parent
      else
        raise "Cannot find ea parent for #{name}"
      end
    end

    def self.name_matches(q)
      where(arel_table[:name].matches(q))
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
