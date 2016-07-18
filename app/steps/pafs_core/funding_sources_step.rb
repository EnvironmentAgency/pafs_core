# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class FundingSourcesStep < BasicStep
    include PafsCore::FundingSources
    delegate :funding_sources_visited, :funding_sources_visited=,
             :funding_sources_visited?,
             to: :project

    validate :at_least_one_funding_source_is_selected

    def update(params)
      result = false
      assign_attributes(step_params(params).merge(funding_sources_visited: true))
      if valid?
        public_contributor_names = nil unless public_contributions?
        private_contributor_names = nil unless private_contributions?
        other_ea_contributor_names = nil unless other_ea_contributions?

        if project.save
          @step = next_step
          result = true
        end
      end
      result
    end

    def previous_step
      :key_dates
    end

    def step
      @step ||= :funding_sources
    end

    def completed?
      if funding_sources_visited? && valid?
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
      ActionController::Parameters.new(params).require(:funding_sources_step).permit(
        :fcerm_gia,
        :local_levy,
        :internal_drainage_boards,
        :public_contributions,
        :private_contributions,
        :other_ea_contributions,
        :growth_funding,
        :not_yet_identified)
    end

    def next_step
      if public_contributions?
        :public_contributors
      elsif private_contributions?
        :private_contributors
      elsif other_ea_contributions?
        :other_ea_contributors
      else
        :funding_values
      end
    end

    def at_least_one_funding_source_is_selected
      errors.add(:base, "You must select at least one funding source") unless
        [fcerm_gia,
         local_levy,
         internal_drainage_boards,
         public_contributions,
         private_contributions,
         other_ea_contributions,
         growth_funding,
         not_yet_identified].any?(&:present?)
    end
  end
end
