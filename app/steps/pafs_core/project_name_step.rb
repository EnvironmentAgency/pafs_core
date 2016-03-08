module PafsCore
  class ProjectNameStep < BasicStep
    delegate :name, :name=, to: :project
    
    validates :name, presence: true

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :step_two
        true
      else
        false
      end
    end

    def previous_step
      ProjectNavigator.first_step
    end

    def step
      @step ||= :project_name
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:project_name_step).permit(:name)
    end
  end
end
