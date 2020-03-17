# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class FundingSourcesStep < BasicStep
    include PafsCore::FundingSources
    include PafsCore::FundingValues

    delegate :funding_sources_visited, :funding_sources_visited=,
             :funding_sources_visited?,
             to: :project

    validate :at_least_one_funding_source_is_selected

    def update(params)
      assign_attributes(step_params(params).merge(funding_sources_visited: true))
      clean_unselected_funding_sources
      funding_values.map(&:save!)

      valid? && project.save
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

    def at_least_one_funding_source_is_selected
      errors.add(:base, "The project must have at least one funding source.") unless
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
