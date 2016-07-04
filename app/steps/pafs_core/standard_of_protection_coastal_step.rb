# frozen_string_literal: true
module PafsCore
  class StandardOfProtectionCoastalStep < BasicStep
    delegate :coastal_protection_before, :coastal_protection_before=,
             :coastal_protection_after, :coastal_protection_after=,
             :project_protects_households?,
             to: :project

    validate :coastal_protection_levels_are_present_and_correct

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
      :standard_of_protection
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

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:standard_of_protection_coastal_step).
        permit(:coastal_protection_before, :coastal_protection_after)
    end

    def coastal_protection_levels_are_present_and_correct
      [:coastal_protection_before, :coastal_protection_after].each { |f| validate_years(f) }
    end

    def validate_years(f)
      v = send(f)
      if v.blank?
        errors.add(f, "can't be blank")
      else
        pc = v.to_i
        if pc < 0 || pc > 100 || (pc.to_s != v.to_s)
          errors.add(f, "must be a value in the range 0 to 100")
        end
      end
    end
  end
end
