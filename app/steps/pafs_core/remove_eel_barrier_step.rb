# frozen_string_literal: true
module PafsCore
  class RemoveEelBarrierStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:remove_eel_barrier_step).
        permit(:remove_eel_barrier)
    end

    def a_choice_has_been_made
      errors.add(:remove_eel_barrier,
                 "^Tell us if the project removes a barrier to migration for "\
                 "eels") if remove_eel_barrier.nil?
    end
  end
end
