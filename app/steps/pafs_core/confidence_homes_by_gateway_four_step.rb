# frozen_string_literal: true

module PafsCore
  class ConfidenceHomesByGatewayFourStep < BasicStep
    include PafsCore::Confidence

    delegate :confidence_homes_by_gateway_four, :confidence_homes_by_gateway_four=,
             to: :project

    validates :confidence_homes_by_gateway_four, presence: { message: "^Select the confidence level" }
    validates :confidence_homes_by_gateway_four, inclusion: {
      in: PafsCore::Confidence::CONFIDENCE_VALUES,
      message: "^Chosen level must be one of the valid values"
    }, if: -> { confidence_homes_by_gateway_four.present? }

    private

    def step_params(params)
      params
        .require(:confidence_homes_by_gateway_four_step)
        .permit(
          :confidence_homes_by_gateway_four
        )
    end
  end
end
