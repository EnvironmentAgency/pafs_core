# frozen_string_literal: true

module PafsCore
  class MainRiskStep < BasicStep
    include PafsCore::Risks
    delegate :project_protects_households?,
             to: :project

    validate :main_risk_is_present_and_a_selected_risk

    private

    def step_params(params)
      params.require(:main_risk_step).permit(:main_risk)
    end

    def main_risk_is_present_and_a_selected_risk
      if main_risk.present?
        m = main_risk
        errors.add(:main_risk, "must be one of the selected risks") unless respond_to?(m) && send(m) == true
      else
        errors.add(:main_risk, "^Select the main risk the project protects against.")
      end
    end
  end
end
