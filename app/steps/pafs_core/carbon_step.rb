# frozen_string_literal: true

module PafsCore
  class CarbonStep < BasicStep
    include PafsCore::Carbon

    validates :carbon_cost_build, presence: { message: "^Add a carbon cost for the build" }
      numericality: true

    validates :carbon_cost_operation,
      presence: { message: "^Add a carbon cost for the operation of the project" },
      numericality: true

  private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:carbon_step)
                                  .permit(
                                    :carbon_cost_build,
                                    :carbon_cost_operation,
                                  )
    end
  end
end

