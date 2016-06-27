# frozen_string_literal: true
module PafsCore
  class SurfaceAndGroundwaterAmountStep < BasicStep
    delegate :improve_surface_or_groundwater?,
             :improve_surface_or_groundwater_amount,
             :improve_surface_or_groundwater_amount=,
             to: :project

    validate :amount_is_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :improve_river
        true
      else
        false
      end
    end

    def previous_step
      :surface_and_groundwater
    end

    def step
      @step ||= :surface_and_groundwater_amount
    end

    # overridden to show this step as part of the 'surface_and_groundwater' step
    def is_current_step?(a_step)
      a_step.to_sym == :surface_and_groundwater
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:surface_and_groundwater_amount_step).
        permit(:improve_surface_or_groundwater_amount)
    end

    def amount_is_present_and_correct
      if improve_surface_or_groundwater_amount.blank?
        errors.add(:improve_surface_or_groundwater_amount,
                   "^Enter a value to show how many kilometers of surface water "\
                   "or groundwater the project will protect or improve.")
      elsif improve_surface_or_groundwater_amount <= 0
        errors.add(:improve_surface_or_groundwater_amount,
                   "^Enter a value greater than zero to show how many kilometers "\
                   "the project will protect or improve.")
      end
    end
  end
end
