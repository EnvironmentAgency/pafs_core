# frozen_string_literal: true
module PafsCore
  class RemoveEelBarrierStep < BasicStep
    delegate :remove_eel_barrier,
      :remove_eel_barrier=,
      :remove_eel_barrier?,
      :remove_fish_barrier?,
      to: :project

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if remove_fish_barrier? || remove_eel_barrier?
                  :fish_or_eel_amount
                else
                  :urgency
                end
        true
      else
        false
      end
    end

    def previous_step
      :habitat_creation
    end

    def step
      @step ||= :remove_eel_barrier
    end

    # overridden to show this step as part of the 'remove_fish_barrier' step
    def is_current_step?(a_step)
      a_step.to_sym == :remove_fish_barrier
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
