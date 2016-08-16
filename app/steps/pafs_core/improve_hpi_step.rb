# frozen_string_literal: true
module PafsCore
  class ImproveHpiStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_hpi_step).
        permit(:improve_hpi)
    end

    def a_choice_has_been_made
      errors.add(:improve_hpi,
                 "^Tell us if the project protects or improves a Habitat of "\
                 "Principal Importance") if improve_hpi.nil?
    end
  end
end
