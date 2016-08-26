# frozen_string_literal: true
module PafsCore
  class LocationStep < BasicStep
    delegate :project_location=,
             :project_location_zoom_level, :project_location_zoom_level=,
             :region, :region=,
             :parliamentary_constituency, :parliamentary_constituency=,
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
      sp[:project_location] = JSON.parse(sp[:project_location]) if sp[:project_location] != nil
      sp[:project_location_zoom_level] = sp[:project_location_zoom_level].to_i
      sp.merge!(extra_geo_data(sp[:project_location])) if !sp[:project_location].nil?
      assign_attributes(sp)
      valid? && project.save
    end

    def before_view(params)
      @results = PafsCore::MapService.new
                                     .find(
                                       params[:q],
                                       project_location || []
                                     )
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:location_step)
                                  .permit(
                                    :project_location,
                                    :project_location_zoom_level)
    end

    def extra_geo_data(location)
      PafsCore::MapService.new.get_extra_geo_data(location)
    end
  end
end
