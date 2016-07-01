# frozen_string_literal: true
module PafsCore
  class RemoveFishBarrierStep < BasicStep
    delegate :remove_fish_barrier,
      :remove_fish_barrier=,
      :remove_fish_barrier?,
      to: :project

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :remove_eel_barrier
        true
      else
        false
      end
    end

    def previous_step
      :habitat_creation
    end

    def step
      @step ||= :remove_fish_barrier
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false if remove_fish_barrier.nil?
      PafsCore::RemoveEelBarrierStep.new(project).completed?
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:remove_fish_barrier_step).
        permit(:remove_fish_barrier)
    end

    def a_choice_has_been_made
      errors.add(:remove_fish_barrier,
                 "^Tell us if the project removes a barrier to migration for "\
                 "fish") if remove_fish_barrier.nil?
    end
  end
end
