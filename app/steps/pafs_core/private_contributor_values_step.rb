# frozen_string_literal: true

module PafsCore
  class PrivateContributorValuesStep < FundingContributorValuesStep
    def param_key
      :private_contributor_values_step
    end

    private

    def contributor_type
      PafsCore::FundingSources::PRIVATE_CONTRIBUTIONS
    end
  end
end
