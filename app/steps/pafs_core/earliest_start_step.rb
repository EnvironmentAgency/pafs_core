# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class EarliestStartStep < BasicStep
    delegate :could_start_early, :could_start_early=, :could_start_early?,
             to: :project

    validate :a_choice_has_been_made

    private

    def step_params(params)
      ActionController::Parameters.new(params).require(:earliest_start_step).permit(:could_start_early)
    end

    def a_choice_has_been_made
      errors.add(:could_start_early, "^Tell us if the project can start earlier") if could_start_early.nil?
    end
  end
end
