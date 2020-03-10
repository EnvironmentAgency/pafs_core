# frozen_string_literal: true

module PafsCore
  class CarbonCostBuildStep < BasicStep
    include PafsCore::Carbon

    validates :carbon_cost_build, presence: { message: "^Add a carbon cost for the build" }
    validates :carbon_cost_build, 
      numericality: { message: "^Please enter a numerical value for carbon cost"},
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


