# frozen_string_literal: true
module PafsCore
  class LocationStep < BasicStep
    delegate :project_location=,
             :project_location_zoom_level, :project_location_zoom_level=,
             :region, :region=,
             :county, :county=,
             :parliamentary_constituency, :parliamentary_constituency=,
             :benefit_area_file_name,
             to: :project

    attr_reader :results

    validates :project_location, presence: true
    validates :project_location_zoom_level, presence: true

    def project_location
      project.project_location || []
    end

    def benefit_area
      project.benefit_area ||= "[[[]]]"
    end

    def update(params)
      sp = step_params(params)
      sp[:project_location] = JSON.parse(sp[:project_location]) unless empty_project_location?(sp[:project_location])
      sp[:project_location_zoom_level] = sp[:project_location_zoom_level].to_i
      sp.merge!(extra_geo_data(sp[:project_location])) if !sp[:project_location].nil?
      assign_attributes(sp)
      valid? && project.save
    end

    def before_view(params)
      if params.fetch(:q, false) || project_location.present?
        @results = PafsCore::MapService.new
                                       .find(
                                         params[:q],
                                         project_location || []
                                       )

        if results.empty? && !params[:q].empty?
          errors.add(:base, "There are no results that match the location you specified")
        end

        errors.add(:base, "Tell us the location of the project") if results.empty? && params[:q].empty?

      else
        @results = []
      end
    end

    def marker
      if project_location.empty?
        [@results.first[:eastings], @results.first[:northings]]
      else
        project_location
      end
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:location_step)
                                  .permit(
                                    :project_location,
                                    :project_location_zoom_level)
    end

    def empty_project_location?(project_location)
      project_location.nil? || project_location.to_s.empty?
    end

    def extra_geo_data(location)
      PafsCore::MapService.new.get_extra_geo_data(location)
    end
  end
end
