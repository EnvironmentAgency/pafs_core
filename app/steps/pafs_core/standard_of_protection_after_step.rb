# frozen_string_literal: true
module PafsCore
  class StandardOfProtectionAfterStep < BasicStep
    delegate :flood_protection_before,
             :flood_protection_after, :flood_protection_after=,
             :coastal_erosion?,
             :project_protects_households?,
             to: :project

    validates :flood_protection_after, presence: {
      message: "^Select the option that shows the potential risk of flooding \
      to the area after the project is complete."
    }

    validates :flood_protection_after, numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 3
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
        @step = if @project.coastal_erosion?
                  :standard_of_protection_coastal
                else
                  :approach
                end
        true
      else
        false
      end
    end

    def previous_step
      :standard_of_protection
    end

    def step
      @step ||= :standard_of_protection_after
    end

    # overridden to show this step as part of the 'standard of protection' step
    def is_current_step?(a_step)
      a_step.to_sym == :standard_of_protection
    end

    def standard_of_protection_options
      [
        :very_significant,
        :significant,
        :moderate,
        :low,
      ].freeze
    end

    # override BasicStep#completed? to handle standard_of_protection_coastal sub-step
    def completed?
      return false unless valid?
      PafsCore::StandardOfProtectionCoastalStep.new(project).completed?
    end

    def disabled?
      !project_protects_households?
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:standard_of_protection_after_step).
        permit(:flood_protection_after)
    end
  end
end
