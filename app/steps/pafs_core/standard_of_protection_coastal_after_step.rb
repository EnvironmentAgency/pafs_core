# frozen_string_literal: true
module PafsCore
  class StandardOfProtectionCoastalAfterStep < BasicStep
    delegate :coastal_protection_after, :coastal_protection_after=,
             :project_protects_households?, :flooding?,
             to: :project

    validates :coastal_protection_after, presence: {
      message: "^Select the option that shows the length of time before coastal \
      erosion affects the area likely to benefit from the project."
    }

    validates :coastal_protection_after, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3,
      allow_blank: true
    }

    # flood protection levels are stored as integers that correlate to
    # the category of risk of flooding
    # 0 - Very significant
    # 1 - Significant
    # 2 - Moderate
    # 3 - Low

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :approach
        true
      else
        false
      end
    end

    def previous_step
      :standard_of_protection_coastal
    end

    def step
      @step ||= :standard_of_protection_coastal_after
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
        :less_than_ten_years,
        :ten_to_nineteen_years,
        :twenty_to_fortynine_years,
        :fifty_years_or_more
      ].freeze
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:standard_of_protection_coastal_after_step).
        permit(:coastal_protection_after)
    end
  end
end
