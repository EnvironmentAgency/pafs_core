# frozen_string_literal: true
module PafsCore
  class StandardOfProtectionCoastalStep < BasicStep
    delegate :coastal_protection_before, :coastal_protection_before=,
             :project_protects_households?, :flooding?,
             to: :project

    validates :coastal_protection_before, presence: {
      message: "^Select the option that shows the length of time before coastal \
      erosion affects the area likely to benefit from the project."
    }

    validates :coastal_protection_before, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3,
      allow_blank: true
    }

    # flood protection levels are stored as integers that correlate to
    # the category of risk of flooding
    # 0 - Less than 1 year
    # 1 - 1 to 4 years
    # 2 - 5 to 9 years
    # 3 - 10 years or more

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :standard_of_protection_coastal_after
        true
      else
        false
      end
    end

    def previous_step
      if flooding?
        :standard_of_protection_after
      else
        :coastal_erosion_protection_outcomes
      end
    end

    def step
      @step ||= :standard_of_protection_coastal
    end

    # overridden to show this step as part of the 'standard of protection' step
    def is_current_step?(a_step)
      a_step.to_sym == :standard_of_protection
    end

    def disabled?
      !project_protects_households?
    end

    def standard_of_protection_options
      [
        :less_than_one_year,
        :one_to_four_years,
        :five_to_nine_years,
        :ten_years_or_more
      ].freeze
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:standard_of_protection_coastal_step).
        permit(:coastal_protection_before)
    end
  end
end
