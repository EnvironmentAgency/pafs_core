# frozen_string_literal: true
module PafsCore
  class StandardOfProtectionCoastalAfterStep < BasicStep
    include PafsCore::StandardOfProtection

    validates :coastal_protection_after, presence: {
      message: "^Select the option that shows the length of time before coastal \
      erosion affects the area likely to benefit after the project is complete."
    }

    validates :coastal_protection_after, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3,
      allow_blank: true
    }

    validate :coastal_protection_improves

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:standard_of_protection_coastal_after_step).
        permit(:coastal_protection_after)
    end

    def coastal_protection_improves
      coastal_erosion_protection_should_be_same_or_better_for(:coastal_protection_after)
    end
  end
end
