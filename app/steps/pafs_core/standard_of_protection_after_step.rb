# frozen_string_literal: true
module PafsCore
  class StandardOfProtectionAfterStep < BasicStep
    include PafsCore::Risks, PafsCore::StandardOfProtection

    validates :flood_protection_after, presence: {
      message: "^Select the option that shows the potential risk of flooding \
      to the area after the project is complete."
    }

    validates :flood_protection_after, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3,
      allow_blank: true
    }

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:standard_of_protection_after_step).
        permit(:flood_protection_after)
    end
  end
end
