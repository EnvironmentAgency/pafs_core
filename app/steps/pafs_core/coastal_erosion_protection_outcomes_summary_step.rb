# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class CoastalErosionProtectionOutcomesSummaryStep < BasicStep
    include PafsCore::Outcomes, PafsCore::Risks

    def update(params)
      # just progress to next step
      true
    end

    # def disabled?
    #   !(coastal_erosion? && !project_end_financial_year.nil? && project_protects_households?)
    # end
    #
    # def completed?
    #   !!(coastal_erosion? && !total_protected_households.zero? && !total_for(:households_at_reduced_risk).zero?)
    # end
  end
end
