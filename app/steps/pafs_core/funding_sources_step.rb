# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  class FundingSourcesStep < BasicStep
    delegate :fcerm_gia, :fcerm_gia=,
             :local_levy, :local_levy=,
             :internal_drainage_boards, :internal_drainage_boards=,
             :public_contributions, :public_contributions=,
             :public_contributor_names, :public_contributor_names=,
             :private_contributions, :private_contributions=,
             :private_contributor_names, :private_contributor_names=,
             :other_ea_contributions, :other_ea_contributions=,
             :other_ea_contributor_names, :other_ea_contributor_names=,
             :growth_funding, :growth_funding=,
             :not_yet_identified, :not_yet_identified=,
             to: :project

    validates :public_contributor_names, presence: true, if: -> { public_contributions}
    validates :private_contributor_names, presence: true, if: -> { private_contributions}
    validates :other_ea_contributor_names, presence: true, if: -> { other_ea_contributions}
    validates :public_contributor_names, absence: true, unless: -> { public_contributions }
    validates :private_contributor_names, absence: true, unless: -> { private_contributions }
    validates :other_ea_contributor_names, absence: true, unless: -> { other_ea_contributions }
    validate :at_least_one_funding_source_is_selected

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
      @step ||= :funding_sources
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:funding_sources_step).permit(
        :fcerm_gia,
        :local_levy,
        :internal_drainage_boards,
        :public_contributions,
        :public_contributor_names,
        :private_contributions,
        :private_contributor_names,
        :other_ea_contributions,
        :other_ea_contributor_names,
        :growth_funding,
        :not_yet_identified)
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