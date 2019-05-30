# frozen_string_literal: true

module PafsCore
  class PublicContributorValuesStep < FundingContributorValuesStep
    def funding_source
      :public_contributors
    end
  end
end

