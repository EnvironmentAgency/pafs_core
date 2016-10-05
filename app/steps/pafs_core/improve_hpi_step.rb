# frozen_string_literal: true
module PafsCore
  class ImproveHpiStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid?
        if project.improve_hpi == false
          # if this is false we will never ask the "improve river" questions
          # so clear the improve_river step data in case they were set previously
          project.improve_river = nil
          project.improve_river_amount = nil
        end
        project.save
      else
        false
      end
    end
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
