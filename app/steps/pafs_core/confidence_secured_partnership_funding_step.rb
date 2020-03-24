# frozen_string_literal: true

module PafsCore
  class ConfidenceSecuredPartnershipFundingStep < BasicStep
    include PafsCore::Confidence

    delegate :confidence_secured_partnership_funding, :confidence_secured_partnership_funding=,
             to: :project

    validates :confidence_secured_partnership_funding, presence: { message: "^Select the confidence level" }
    validates :confidence_secured_partnership_funding, inclusion: {
      in: PafsCore::Confidence::CONFIDENCE_VALUES,
      message: "^Chosen level must be one of the valid values"
    }, if: -> { confidence_secured_partnership_funding.present? }

    private

    def step_params(params)
      params
        .require(:confidence_secured_partnership_funding_step)
        .permit(
          :confidence_secured_partnership_funding
        )
    end
  end
end
