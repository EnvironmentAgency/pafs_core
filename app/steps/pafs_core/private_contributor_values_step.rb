# frozen_string_literal: true

module PafsCore
  class PrivateContributorValuesStep < FundingContributorValuesStep
    def funding_source
      :private_contributors
    end
  end
end


