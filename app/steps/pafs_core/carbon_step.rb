# frozen_string_literal: true

module PafsCore
  class CarbonStep < BasicStep
    include PafsCore::Carbon

    validates :carbon_cost_build,
      presence: { message: "^Add a carbon cost for the build" },
      numericality: true

    validates :carbon_cost_operation,
      presence: { message: "^Add a carbon cost for the operation of the project" },
      numericality: true

    validates :carbon_sequestered,
      presence: { message: "^Add a carbon sequestered value for the build" },
      numericality: true

  private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:carbon_step)
                                  .permit(
                                    :carbon_cost_build,
                                    :carbon_cost_operation,
                                    :carbon_sequestered
                                  )
    end
  end
end

