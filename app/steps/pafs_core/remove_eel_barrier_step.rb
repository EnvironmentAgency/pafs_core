# frozen_string_literal: true
module PafsCore
  class RemoveEelBarrierStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      valid? && project.save
    end

    def step
      @step ||= :remove_eel_barrier
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false if remove_eel_barrier.nil?
      return true unless remove_fish_barrier? || remove_eel_barrier?

      PafsCore::FishOrEelAmountStep.new(project).completed?
    end

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
