# frozen_string_literal: true

module PafsCore
  class ApproachStep < BasicStep
    delegate :approach, :approach=,
             :project_protects_households?,
             to: :project

    validates :approach, presence: {
      message: "^Tell us about the work the project plans to do to achieve " \
      "its benefits."
    }

    private

    def step_params(params)
      params.require(:approach_step).permit(:approach)
    end
  end
end
