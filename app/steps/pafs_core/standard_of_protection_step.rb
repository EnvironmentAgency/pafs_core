# frozen_string_literal: true
module PafsCore
  class StandardOfProtectionStep < BasicStep
    delegate :flood_protection_before, :flood_protection_before=,
             :project_protects_households?, :coastal_erosion?,
             to: :project

    validates :flood_protection_before, presence: {
      message:
      "^Select the option that shows the current risk of flooding to the area \
      likely to benefit from the project."
    }

    validates :flood_protection_before, numericality: {
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
        @step = :standard_of_protection_after
        true
      else
        false
      end
    end

    def previous_step
      if coastal_erosion?
        :coastal_erosion_protection_outcomes
      else
        :flood_protection_outcomes
      end
    end

    def step
      @step ||= :standard_of_protection
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
      if coastal_erosion?
        return false unless valid?
        PafsCore::StandardOfProtectionCoastalStep.new(project).completed?
      else
        valid?
      end
    end

    def disabled?
      !project_protects_households?
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:standard_of_protection_step).
        permit(:flood_protection_before, :flood_protection_after)
    end
  end
end
