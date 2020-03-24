# frozen_string_literal: true

module PafsCore
  class CarbonCostOperationStep < BasicStep
    include PafsCore::Carbon

    validates :carbon_cost_operation, presence: { message: "^Add a numerical value for Carbon over the lifecycle of the project's assets" }
    validates :carbon_cost_operation,
              numericality: {
                greater_than_or_equal_to: 0,
                only_integer: true,
                message: "^Add a numerical value for Carbon over the lifecycle of the project's assets"
              },
              unless: -> { carbon_cost_operation.blank? }

    private

    def step_params(params)
      params
        .require(:carbon_cost_operation_step)
        .permit(
          :carbon_cost_operation
        )
    end
  end
end
