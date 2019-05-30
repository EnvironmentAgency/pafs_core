# frozen_string_literal: true

module PafsCore
  class PrivateContributorsStep < FundingContributorsStep
    def private_contributions?
      false
    end

    def funding_source
      :private_contributions
    end
  end
end
