# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class LocationStep < BasicStep
    delegate :project_location, :project_location=,
             :project_location_zoom_level, :project_location_zoom_level=,
             :region, :region=,
             :parliamentary_constituency, :parliamentary_constituency=,
             to: :project

    validates :project_location, presence: true
    validates :project_location_zoom_level, presence: true

    def previous_step
      :key_dates
    end

    def benefit_area
      project.benefit_area ||= "[[[]]]"
    end

    def step
      @step ||= :location
    end

    def update(params)
      sp = step_params(params)

      sp[:project_location] = JSON.parse(sp[:project_location]) if sp[:project_location] != nil
      sp[:project_location_zoom_level] = sp[:project_location_zoom_level].to_i
      assign_attributes(sp)
      if valid? && project.save
        extra_geo_data = PafsCore::MapService.new.get_extra_geo_data(sp[:project_location])
        project.update(extra_geo_data)
        @step = :map
        true
      else
        false
      end
    end

    def completed?
      valid? && self.project_location != []
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:location_step)
                                  .permit(
                                    :project_location,
                                    :project_location_zoom_level)
    end
  end
end
