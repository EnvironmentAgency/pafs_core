# frozen_string_literal: true

module PafsCore
  class FloodProtectionOutcomesSummaryStep < BasicStep
    include PafsCore::Risks
    include PafsCore::Outcomes
    delegate :project_protects_households?,
             to: :project

    def update(_params)
      # do nothing
      true
    end
  end
end
