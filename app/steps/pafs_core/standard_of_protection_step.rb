# frozen_string_literal: true
module PafsCore
  class StandardOfProtectionStep < BasicStep
    delegate :flood_protection_before, :flood_protection_before=,
             :flood_protection_after, :flood_protection_after=,
             :project_protects_households?,
             to: :project

    validate :flood_protection_levels_are_present_and_correct

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :standard_of_protection_coastal
        true
      else
        false
      end
    end

    def previous_step
      :coastal_erosion_protection_outcomes
    end

    def step
      @step ||= :standard_of_protection
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
      ActionController::Parameters.new(params).require(:standard_of_protection_step).
        permit(:flood_protection_before, :flood_protection_after)
    end

    def flood_protection_levels_are_present_and_correct
      [:flood_protection_before, :flood_protection_after].each { |f| validate_percentage(f) }
    end

    def validate_percentage(f)
      v = send(f)
      if v.blank?
        errors.add(f, "can't be blank")
      else
        pc = v.to_i
        if pc < 0 || pc > 100 || (pc.to_s != v.to_s)
          errors.add(f, "must be a percentage value in the range 0 to 100")
        end
      end
    end
  end
end
