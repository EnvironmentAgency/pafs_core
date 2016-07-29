# frozen_string_literal: true
module PafsCore
  class ProjectNameStep < BasicStep
    delegate :name, :name=, to: :project

    validates :name, presence: true

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:project_name_step).permit(:name)
    end
  end
end
