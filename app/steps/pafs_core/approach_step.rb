# frozen_string_literal: true
module PafsCore
  class ApproachStep < BasicStep
    delegate :approach, :approach=,
             :project_protects_households?,
             to: :project

    validates :approach, presence: { message: "^Please enter a description" }

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:approach_step).permit(:approach)
    end
  end
end
