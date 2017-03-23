# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "bstard"

module PafsCore
  class Project < ActiveRecord::Base
    validates :reference_number, presence: true, uniqueness: { scope: :version }
    validates :reference_number, format: { with: /\A(AC|AE|AN|NO|NW|SN|SO|SW|TH|TR|TS|WX|YO)C501E\/\d{3}A\/\d{3}A\z/,
                                           message: "has an invalid format" }
    validates :version, presence: true

    belongs_to :creator, class_name: "User"
    has_many :area_projects
    has_many :areas, through: :area_projects
    has_many :funding_values
    has_many :flood_protection_outcomes
    has_many :coastal_erosion_protection_outcomes
    has_one :state, inverse_of: :project
    has_many :asite_submissions, inverse_of: :project
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
      fluvial_flooding? || tidal_flooding? || groundwater_flooding? ||
        surface_water_flooding? || sea_flooding? || reservoir_flooding?
    end

    def project_protects_households?
      project_type != "ENV_WITHOUT_HOUSEHOLDS"
    end

    # rubocop:disable Style/HashSyntax
    def submission_state
      machine = Bstard.define do |fsm|
        fsm.initial current_state
        fsm.event :complete, :draft => :completed
        fsm.event :submit, :completed => :submitted
        fsm.event :unlock, :completed => :draft, :submitted => :draft
        fsm.when :any do |_event, _prev_state, new_state|
          state.state = new_state
          state.save!
        end
      end
    end
    # rubocop:enable Style/HashSyntax

    def draft?
      current_state == "draft"
    end

    def completed?
      current_state == "completed"
    end

    def submitted?
      current_state == "submitted"
    end

    def status
      current_state.to_sym
    end

    def total_for_funding_source(fs)
      source_total = 0
      funding_values.each do |fv|
        source_total = source_total + fv[fs].to_i
      end
      source_total
    end

    def total_households_flood_protected_by_category(category)
      households = 0
      flood_protection_outcomes.each do |fo|
        households = households + fo[category].to_i
      end
      households
    end

    def total_households_coastal_protected_by_category(category)
      households = 0
      coastal_erosion_protection_outcomes.each do |fo|
        households = households + fo[category].to_i
      end
      households
    end

  private
    def set_slug
      self.slug = reference_number.parameterize.upcase
    end

    def current_state
      create_state(state: "draft") if state.nil?
      state.state || "draft"
    end
  end
end
