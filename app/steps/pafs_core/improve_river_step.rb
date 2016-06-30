# frozen_string_literal: true
module PafsCore
  class ImproveRiverStep < BasicStep
    delegate :improve_river,
      :improve_river=,
      :improve_river?,
      to: :project

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :habitat_improvement
        true
      else
        false
      end
    end

    def previous_step
      :surface_and_groundwater_amount
    end

    def step
      @step ||= :improve_river
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_river_step).
        permit(:improve_river)
    end

    def a_choice_has_been_made
      errors.add(:improve_river,
                 "^Tell us if the project protects or improves a length of river "\
                 "or priority river habitat") if improve_river.nil?
    end
  end
end
