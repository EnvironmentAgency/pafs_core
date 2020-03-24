# frozen_string_literal: true

module PafsCore
  module Confidence
    CONFIDENCE_VALUES = %w[
      high
      medium_high
      medium_low
      low
      not_applicable
    ].freeze

    delegate :confidence_homes_better_protected, :confidence_homes_better_protected=,
             :confidence_homes_by_gateway_four, :confidence_homes_by_gateway_four=,
             :confidence_secured_partnership_funding, :confidence_secured_partnership_funding=,
             to: :project
  end
end
