# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class MainRiskStep < BasicStep
    include PafsCore::Risks
    delegate :project_protects_households?,
             to: :project

    validate :main_risk_is_present_and_a_selected_risk

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:main_risk_step).permit(:main_risk)
    end

    def main_risk_is_present_and_a_selected_risk
      if main_risk.present?
        m = main_risk
        errors.add(:main_risk, "must be one of the selected risks") unless self.respond_to?(m) && self.send(m) == true
      else
        errors.add(:main_risk, "^A main source of risk must be selected")
      end
    end
  end
end
