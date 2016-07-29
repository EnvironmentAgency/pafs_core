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

    # def disabled?
    #   !(flooding? && !project_end_financial_year.nil? && project_protects_households?)
    # end
    #
    # def completed?
    #   !!(flooding? && !current_flood_protection_outcomes.empty? && !total_for(:households_at_reduced_risk).zero?)
    # end
  end
end
