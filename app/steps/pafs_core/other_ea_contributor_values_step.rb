# frozen_string_literal: true

module PafsCore
  class OtherEaContributorValuesStep < FundingContributorValuesStep
    def funding_source
      :other_ea_contributors
    end
  end
end

