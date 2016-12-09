# frozen_string_literal: true
module PafsCore
  class LocationStep < BasicStep
    delegate :grid_reference, :grid_reference=,
             :benefit_area_file_name,
             to: :project

    validate :grid_reference_is_supplied

  private
    def step_params(params)
      ActionController::Parameters.new(params)
                                  .require(:location_step)
                                  .permit(:grid_reference)
    end

    def grid_reference_is_supplied
      if grid_reference.present?
        # check format
        r = grid_reference.delete("\s").upcase
        errors.add(:grid_reference,
                   "^The National Grid Reference must be 2 letters "\
                   "followed by 10 digits") unless r =~ /\A[HJNOST][A-Z]\d{10}\z/
      else
        errors.add(:grid_reference, "^Tell us the project's National Grid Reference")
      end
    end
  end
end
