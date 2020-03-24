# frozen_string_literal: true

module PafsCore
  class ProjectAreaStep < BasicStep
    delegate :rma_name, :rma_name=, to: :project

    validates :rma_name, presence: { message: "^Select a lead PSO area" }

    private

    def step_params(params)
      params.require(:project_area_step).permit(:rma_name)
    end
  end
end
