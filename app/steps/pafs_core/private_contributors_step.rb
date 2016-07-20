# frozen_string_literal: true
module PafsCore
  class PrivateContributorsStep < BasicStep
    delegate :private_contributor_names,
             :private_contributor_names=,
             :other_ea_contributions?,
             to: :project

    validates :private_contributor_names, presence: { message: "^Tell us the private sector contributors." }

    def update(params)
      assign_attributes(step_params(params))
      if valid? && project.save
        @step = next_step
        true
      else
        false
      end
    end

    def previous_step
      :key_dates
    end

    def step
      @step ||= :private_contributors
    end

    # overridden to show this step as part of the 'funding_sources' step
    def is_current_step?(a_step)
      a_step.to_sym == :funding_sources
    end

    def completed?
      if valid?
        step = next_step
        if step != :funding_values
          PafsCore::ProjectNavigator.build_project_step(project, next_step, user).completed?
        else
          true
        end
      else
        false
      end
    end
  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:private_contributors_step).
        permit(:private_contributor_names)
    end

    def next_step
      if other_ea_contributions?
        :other_ea_contributors
      else
        :funding_values
      end
    end
  end
end
