# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class EarliestStartStep < BasicStep
    delegate :could_start_early, :could_start_early=, :could_start_early?,
             to: :project

    validate :a_choice_has_been_made

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if could_start_early?
                  :earliest_date
                else
                  :location
                end
        true
      else
        false
      end
    end

    # override BasicStep#completed? to handle earliest_date step
    def completed?
      return false if could_start_early.nil?
      # if 'No' selected then no sub-step needed
      return true if !could_start_early?

      sub_step = PafsCore::EarliestDateStep.new(project)
      sub_step.completed?
    end

    def previous_step
      :funding_values
    end

    def step
      @step ||= :earliest_start
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:earliest_start_step).permit(:could_start_early)
    end

    def a_choice_has_been_made
      errors.add(:could_start_early, "^You must select either yes or no") if could_start_early.nil?
    end
  end
end
