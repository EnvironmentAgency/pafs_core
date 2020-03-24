# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  class CoastalErosionProtectionOutcomesSummaryStep < BasicStep
    include PafsCore::Risks
    include PafsCore::Outcomes

    def update(_params)
      # just progress to next step
      true
    end
  end
end
