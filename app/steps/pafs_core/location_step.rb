# frozen_string_literal: true
module PafsCore
  class LocationStep < BasicStep
    delegate :project_location=,
             :project_location_zoom_level, :project_location_zoom_level=,
             to: :project

    attr_reader :results

    validates :project_location, presence: true
    validates :project_location_zoom_level, presence: true

    def project_location
      project.project_location || []
    end

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
      valid? && project.save
    end

    def completed?
      valid? && self.project_location != []
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
                                  .permit(:project_location, :project_location_zoom_level)
    end
  end
end
