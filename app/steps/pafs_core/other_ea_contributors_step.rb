# frozen_string_literal: true

module PafsCore
  class OtherEaContributorsStep < FundingContributorsStep
    def funding_source
      :other_ea_contributions
    end
  end
end
