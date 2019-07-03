# frozen_string_literal: true

module PafsCore
  class PublicContributorValuesStep < FundingContributorValuesStep
    def param_key
      :public_contributor_values_step
    end

    private

    def contributor_type
      PafsCore::FundingSources::PUBLIC_CONTRIBUTIONS
    end
  end
end

