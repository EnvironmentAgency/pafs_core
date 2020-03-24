# frozen_string_literal: true

module PafsCore
  class ProjectTypeStep < BasicStep
    delegate :project_type, :project_type=,
             to: :project

    validates :project_type,
              inclusion: { in: PafsCore::PROJECT_TYPES,
                           message: "^Select a project type" }

    private

    def step_params(params)
      params.require(:project_type_step).permit(:project_type)
    end
  end
end
