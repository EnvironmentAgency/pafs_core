# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class KeyDatesStep < BasicStep
    def step
      @step ||= :key_dates
    end
  end
end
