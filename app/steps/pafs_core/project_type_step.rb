# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ProjectTypeStep < BasicStep
    delegate :project_type, :project_type=,
             :environmental_type, :environmental_type=,
             to: :project

    validates :project_type,
      inclusion: { in: PafsCore::PROJECT_TYPES,
                   message: "^Select a project type" }

    validates :environmental_type,
      inclusion: { in: PafsCore::ENVIRONMENTAL_TYPES,
                   message: "^Select an environmental type" }, if: :environmental_project?

    def update(params)
      assign_attributes(step_params(params))
      # clear the :environmental_type for non-environmental project types
      self.environmental_type = nil unless environmental_project?

      if valid? && project.save
        @step = :financial_year
        true
      else
        false
      end
    end

    def previous_step
      :project_name
    end

    def step
      @step ||= :project_type
    end

    def environmental_project?
      project_type == "ENV"
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:project_type_step).permit(:project_type, :environmental_type)
    end
  end
end
