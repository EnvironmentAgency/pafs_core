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

    URGENCY_CODES = {
      "statutory_need" => "BS",
      "legal_need" => "BL",
      "health_and_safety" => "HS",
      "emergency_works" => "EM",
      "time_limited" => "TL"
    }.freeze

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

    def urgency_code
      URGENCY_CODES.fetch(urgency_reason, "") if urgency_reason.present?
    end

    def urgency_from_string(str)
      I18n.t("pafs_core.fcerm1.moderation").invert[str]
    end
  end
end
