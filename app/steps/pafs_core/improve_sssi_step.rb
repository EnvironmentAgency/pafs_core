# frozen_string_literal: true
module PafsCore
  class ImproveSssiStep < BasicStep
    include PafsCore::EnvironmentalOutcomes

    validate :a_choice_has_been_made

    # override BasicStep#completed? to handle earliest_date step
    # def completed?
    #   return false if improve_sssi.nil?
    #
    #   if improve_sssi?
    #     PafsCore::ImproveHabitatAmountStep.new(project).completed?
    #   else
    #     PafsCore::ImproveHpiStep.new(project).completed?
    #   end
    # end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:improve_sssi_step).
        permit(:improve_sssi)
    end

    def a_choice_has_been_made
      errors.add(:improve_sssi,
                 "^Tell us if the project protects or improves a Site of Special "\
                 "Scientific Interest") if improve_sssi.nil?
    end
  end
end
