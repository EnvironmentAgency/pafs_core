# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class FloodProtectionOutcomesSummaryStep < BasicStep
    include PafsCore::Outcomes, PafsCore::Risks
    delegate :project_protects_households?,
             to: :project

    def update(params)
      # do nothing
      true
    end
  end
end
