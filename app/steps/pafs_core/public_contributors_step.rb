# frozen_string_literal: true

module PafsCore
  class PublicContributorsStep < FundingContributorsStep
    def public_contributions?
      false
    end

    def funding_source
      :public_contributions
    end
  end
end
