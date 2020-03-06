# frozen_string_literal: true

module PafsCore
  class ConfidenceHomesBetterProtectedStep < BasicStep
    include PafsCore::Confidence

    delegate :confidence_homes_better_protected, :confidence_homes_better_protected=,
             to: :project

    validates :confidence_homes_better_protected, 
      presence: { message: "^Select the confidence level" },
      inclusion: { 
        in: PafsCore::Confidence::CONFIDENCE_VALUES,
        message: "^Chosen level must be one of the valid values"
      }

  private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:confidence_homes_better_protected_step)
                                  .permit(
                                    :confidence_homes_better_protected
                                  )
    end
  end
end

