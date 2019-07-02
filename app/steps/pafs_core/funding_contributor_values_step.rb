# frozen_string_literal: true

module PafsCore
  class FundingContributorValuesStep < BasicStep
    include PafsCore::FundingValues

    delegate :funding_contributors,
             :funding_contributors_attributes,
             :funding_contributors_attributes=,
             to: :project

    def update(params)
      return false unless at_least_one_value(params)

      PafsCore::FundingContributor.transaction do
        step_params(params)["funding_contributors"].each do |id, attrs|
          funding_contributors.find(id).update!(attrs)
        end
      end
    end
    #
    # override to allow us to set up the funding_values if needed
    def before_view(params)
      setup_funding_values
    end

    def param_key
      :private_contributor_values_step
    end

    private

    def at_least_one_value(params)
      attributes = step_params(params)["funding_contributors"].values

      contributor_names = attributes.map { |attrs| attrs['name'] }.uniq
      contributors_with_at_least_one_value = attributes.map do |attrs| 
        attrs['amount'].to_i > 0 ? attrs['name'] : nil
      end.compact.uniq

      return true if (contributor_names - contributors_with_at_least_one_value).empty?

      errors.add(:base, "Please ensure you enter at lease one value for every contributor")
      false
    end

    def step_params(params)
      ActionController::Parameters.new(params).require(param_key).permit(
        funding_contributors: [
          :id,
          :amount,
          :secured,
          :constrained,
          :name
        ]
      )
    end
  end
end
