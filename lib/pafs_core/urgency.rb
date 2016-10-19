# frozen_string_literal: true
module PafsCore
  module Urgency
    # Urgency reasons
    URGENCY_REASONS = %w[ not_urgent
                          statutory_need
                          legal_need
                          health_and_safety
                          emergency_works
                          time_limited ].freeze

    delegate :urgency_reason, :urgency_reason=,
             :urgency_details, :urgency_details=,
             :urgency_details_updated_at, :urgency_details_updated_at=,
             to: :project

    def urgent?
      urgency_reason.present? && urgency_reason != "not_urgent"
    end

    def not_urgent?
      urgency_reason.present? && urgency_reason == "not_urgent"
    end
  end
end
