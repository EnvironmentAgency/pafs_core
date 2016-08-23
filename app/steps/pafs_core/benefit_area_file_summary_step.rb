# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class BenefitAreaFileSummaryStep < BasicStep

    delegate :benefit_area, :benefit_area=,
    :benefit_area_zoom_level, :benefit_area_zoom_level=,
    :benefit_area_centre, :benefit_area_centre=,
    :project_location, :project_location?, :project_location_zoom_level,
    :benefit_area_file_name, :benefit_area_file_name=,
    :benefit_area_content_type, :benefit_area_content_type=,
    :benefit_area_file_size, :benefit_area_file_size=,
    :benefit_area_file_updated_at, :benefit_area_file_updated_at=,
    :benefit_area?, :benefit_area_file_name?, :storage_path,
    to: :project

    attr_reader :benefit_area_file
    attr_accessor :virus_info

    #validate :presence_of_file_or_area

    def update
      true
    end
  end
end
