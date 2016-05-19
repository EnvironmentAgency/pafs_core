# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class MapStep < BasicStep

    delegate :benefit_area, :benefit_area=,
             :benefit_area_zoom_level, :benefit_area_zoom_level=,
             :benefit_area_centre, :benefit_area_centre=,
             :project_location,
             to: :project

    validates_presence_of :benefit_area, :benefit_area_centre, :benefit_area_zoom_level

    def previous_step
      :location
    end

    def step
      @step ||= :map
    end

    def update(params)
      sp = step_params(params)

      sp[:benefit_area_centre] = JSON.parse(sp[:benefit_area_centre]) if sp[:benefit_area_centre] != nil
      sp[:benefit_area_zoom_level] = sp[:benefit_area_zoom_level].to_i
      assign_attributes(sp)
      if valid? && project.save
        @step = :risks
        true
      else
        false
      end
    end

    def completed?
      valid? && self.benefit_area != ""
    end

    def disabled?
      self.project_location == [] ? true : false
    end

    private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:map_step)
                                  .permit(:benefit_area,
                                          :benefit_area_centre,
                                          :benefit_area_zoom_level)
    end
  end
end
