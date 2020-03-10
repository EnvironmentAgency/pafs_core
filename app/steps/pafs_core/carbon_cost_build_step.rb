# frozen_string_literal: true

module PafsCore
  class CarbonCostBuildStep < BasicStep
    include PafsCore::Carbon

    validates :carbon_cost_build, presence: { message: "^Add a numerical value for Capital carbon" }
    validates :carbon_cost_build, 
      numericality: { message: "^Add a numerical value for Capital carbon"},
      unless: -> { carbon_cost_build.blank? }

  private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:carbon_cost_build_step)
                                  .permit(
                                    :carbon_cost_build
                                  )
    end
  end
end


