# frozen_string_literal: true

module PafsCore
  class ImproveSssiStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    private

    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:improve_sssi_step)
                                  .permit(:improve_sssi)
    end

    def a_choice_has_been_made
      if improve_sssi.nil?
        errors.add(:improve_sssi,
                   "^Tell us if the project protects or improves a Site of Special "\
                   "Scientific Interest")
      end
    end
  end
end
