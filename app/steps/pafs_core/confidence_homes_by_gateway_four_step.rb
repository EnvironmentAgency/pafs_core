# frozen_string_literal: true

module PafsCore
  class ConfidenceHomesByGatewayFourStep < BasicStep
    include PafsCore::Confidence

    delegate :confidence_homes_by_gateway_four, :confidence_homes_by_gateway_four=,
             to: :project

    validates :confidence_homes_by_gateway_four,
      presence: { message: "^Select the confidence level" },
      inclusion: { 
        in: PafsCore::Confidence::CONFIDENCE_VALUES,
        message: "^Chosen level must be one of the valid values"
      }

  private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:confidence_homes_by_gateway_four_step)
                                  .permit(
                                    :confidence_homes_by_gateway_four
                                  )
    end
  end
end


