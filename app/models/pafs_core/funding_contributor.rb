# frozen_string_literal: true

module PafsCore
  class FundingContributor < ApplicationRecord
    belongs_to :funding_value
  end
end
