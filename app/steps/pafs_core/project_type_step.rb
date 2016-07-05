# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class ProjectTypeStep < BasicStep
    delegate :project_type, :project_type=,
             to: :project

    validates :project_type,
      inclusion: { in: PafsCore::PROJECT_TYPES,
                   message: "^Select a project type" }

    def update(params)
      assign_attributes(step_params(params))

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

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:project_type_step).permit(:project_type)
    end
  end
end
