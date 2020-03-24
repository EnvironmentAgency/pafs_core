# frozen_string_literal: true

module PafsCore
  class ImproveRiverStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    private

    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:improve_river_step)
                                  .permit(:improve_river)
    end

    def a_choice_has_been_made
      if improve_river.nil?
        errors.add(:improve_river,
                   "^Tell us if the project protects or improves a length of river "\
                   "or priority river habitat")
      end
    end
  end
end
