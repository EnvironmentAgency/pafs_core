# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class Project < ActiveRecord::Base
    validates :reference_number, presence: true, uniqueness: { scope: :version }
    validates :reference_number, format: { with: /\A(AC|AE|AN|NO|NW|SN|SO|SW|TH|TR|WX|YO)C501E\/\d{3}A\/\d{3}A\z/,
                                           message: "has an invalid format" }
    validates :version, presence: true

    belongs_to :creator, class_name: "User"
    has_many :area_projects
    has_many :areas, through: :area_projects
    has_many :funding_values
    has_many :flood_protection_outcomes
    has_many :coastal_erosion_protection_outcomes
    accepts_nested_attributes_for :funding_values, allow_destroy: true
    accepts_nested_attributes_for :flood_protection_outcomes, allow_destroy: true
    accepts_nested_attributes_for :coastal_erosion_protection_outcomes, allow_destroy: true

    before_validation :set_slug, on: :create

    def to_param
      slug
    end

    def owner
      area_projects.ownerships.map(&:area).first
    end

    def storage_path
      @storage_path ||= File.join(to_param, version.to_s)
    end

    def flooding?
      fluvial_flooding? || tidal_flooding? || groundwater_flooding? || surface_water_flooding? || sea_flooding?
    end

    def project_protects_households?
      project_type != "ENV_WITHOUT_HOUSEHOLDS"
    end

  private
    def set_slug
      self.slug = reference_number.parameterize.upcase
    end
  end
end
