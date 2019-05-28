module PafsCore
  class FundingContributor < ActiveRecord::Base
    belongs_to :funding_value
  end
end
