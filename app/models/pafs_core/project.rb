# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class Project < ActiveRecord::Base
    validates :reference_number, presence: true, uniqueness: { scope: :version }
    validates :reference_number, format: { with: /\AP[A-F0-9]{6}\z/, message: "has an invalid format" }
    validates :version, presence: true

    has_many :area_projects
    has_many :areas, through: :area_projects

    def to_param
      reference_number
    end

    def owner
      area_projects.ownerships.map(&:area).first
    end
  end
end
