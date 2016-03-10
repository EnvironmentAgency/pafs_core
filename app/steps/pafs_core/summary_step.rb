# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  # NOTE: this is just a placeholder for now
  class SummaryStep < BasicStep
    def update(params)
      true
    end

    def previous_step
      ProjectNavigator.first_step
    end

    def step
      @step ||= :summary
    end
  end
end
