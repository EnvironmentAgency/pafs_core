# frozen_string_literal: true
module PafsCore
  class ApproachStep < BasicStep
    delegate :approach, :approach=,
             to: :project

    validates :approach, presence: { message: "^Please enter a description" }

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :surface_and_groundwater
        true
      else
        false
      end
    end

    def previous_step
      :standard_of_protection
    end

    def step
      @step ||= :approach
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:approach_step).permit(:approach)
    end
  end
end
