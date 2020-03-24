# frozen_string_literal: true

module PafsCore
  class SurfaceAndGroundwaterAmountStep < BasicStep
    delegate :improve_surface_or_groundwater?,
             :improve_surface_or_groundwater_amount,
             :improve_surface_or_groundwater_amount=,
             to: :project

    validate :amount_is_present_and_correct

    private

    def step_params(params)
      params
        .require(:surface_and_groundwater_amount_step)
        .permit(:improve_surface_or_groundwater_amount)
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
