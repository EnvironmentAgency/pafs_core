# frozen_string_literal: true

module PafsCore
  class RemoveFishBarrierStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    private

    def step_params(params)
      params
        .require(:remove_fish_barrier_step)
        .permit(:remove_fish_barrier)
    end

    def a_choice_has_been_made
      if remove_fish_barrier.nil?
        errors.add(:remove_fish_barrier,
                   "^Tell us if the project removes a barrier to migration for "\
                   "fish")
      end
    end
  end
end
