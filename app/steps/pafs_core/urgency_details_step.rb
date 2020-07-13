# frozen_string_literal: true

module PafsCore
  class UrgencyDetailsStep < BasicStep
    include PafsCore::Urgency

    # validates :urgency_details, presence: true
    validate :urgency_details_are_present

    def update(params)
      old_details = urgency_details
      result = super
      if result
        project.update(urgency_details_updated_at: Time.zone.now) if urgency_details != old_details
      end
      result
    end

    private

    def step_params(params)
      params.require(:urgency_details_step).permit(:urgency_details)
    end

    def urgency_details_are_present
      unless urgency_details.present?
        errors.add(
          :urgency_details,
          I18n.t("#{urgency_reason}_error", scope: "pafs_core.urgency_details")
        )
      end
    end
  end
end
