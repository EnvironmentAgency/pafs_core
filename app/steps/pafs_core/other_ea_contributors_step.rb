# frozen_string_literal: true
module PafsCore
  class OtherEaContributorsStep < BasicStep
    delegate :other_ea_contributor_names,
             :other_ea_contributor_names=,
             to: :project

    validates :other_ea_contributor_names, presence: true

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = :funding_values
        true
      else
        false
      end
    end

    def previous_step
      :key_dates
    end

    def step
      @step ||= :other_ea_contributors
    end

    # overridden to show this step as part of the 'funding_sources' step
    def is_current_step?(a_step)
      a_step.to_sym == :funding_sources
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:other_ea_contributors_step).
        permit(:other_ea_contributor_names)
    end
  end
end
