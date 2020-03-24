# frozen_string_literal: true

module PafsCore
  class RemoveEelBarrierStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    private

    def step_params(params)
      params
        .require(:remove_eel_barrier_step)
        .permit(:remove_eel_barrier)
    end

    def a_choice_has_been_made
      if remove_eel_barrier.nil?
        errors.add(:remove_eel_barrier,
                   "^Tell us if the project removes a barrier to migration for "\
                   "eels")
      end
    end
  end
end
