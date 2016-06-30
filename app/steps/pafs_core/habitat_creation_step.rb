# frozen_string_literal: true
module PafsCore
  class HabitatCreationStep < BasicStep
    delegate :create_habitat,
      :create_habitat=,
      :create_habitat?,
      to: :project

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if create_habitat?
                  :habitat_creation_amount
                else
                  :remove_fish_barrier
                end
        true
      else
        false
      end
    end

    def previous_step
      :improve_spa_or_sac
    end

    def step
      @step ||= :habitat_creation
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false if create_habitat.nil?
      return true unless create_habitat?
      PafsCore::HabitatCreationAmountStep.new(project).completed?
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:habitat_creation_step).
        permit(:create_habitat)
    end

    def a_choice_has_been_made
      errors.add(:create_habitat,
                 "^Tell us if the project creates habitat") if create_habitat.nil?
    end
  end
end
