# frozen_string_literal: true

module PafsCore
  class OtherEaContributorValuesStep < FundingContributorValuesStep
    def param_key
      :other_ea_contributor_values_step
    end

    private

    def contributor_type
      PafsCore::FundingSources::EA_CONTRIBUTIONS
    end
  end
end

