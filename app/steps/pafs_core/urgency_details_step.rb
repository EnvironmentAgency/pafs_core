# frozen_string_literal: true
module PafsCore
  class UrgencyDetailsStep < BasicStep
    include PafsCore::Urgency

    validates :urgency_details, presence: true

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:urgency_details_step).permit(:urgency_details)
    end
  end
end
