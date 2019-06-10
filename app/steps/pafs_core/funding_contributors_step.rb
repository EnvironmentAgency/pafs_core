# frozen_string_literal: true

module PafsCore
  class FundingContributorsStep < BasicStep
    include PafsCore::FundingSources
    include PafsCore::FundingValues

    def funding_source
      :public_contributions
    end

    def current_funding_contributors
      return [''] if (fv = funding_values.first).nil?
      return [''] if (fc = fv.send(funding_source)).empty?

      fc.map(&:name)
    end

    def funding_contributors_to_delete(params)
      @funding_contributors_to_delete ||= current_funding_contributors - step_params(params)
    end

    def delete_removed_contributors(params)
      funding_values.find_each do |fv|
        PafsCore::FundingContributor.where(funding_value: fv).where(name: funding_contributors_to_delete(params)).destroy_all
      end
    end

    def create_new_contributors(params)
      (step_params(params) - current_funding_contributors).each do |name|
        funding_values.find_each do |fv|
          next if name.strip.blank?
          fv.send(funding_source).create(name: name)
        end
      end
    end

    def update(params)
      return false unless at_least_one_name(params)

      PafsCore::FundingContributor.transaction do
        setup_funding_values
        clean_unselected_funding_sources

        funding_values.reload
        delete_removed_contributors(params)
        create_new_contributors(params)
      end
    end

    private

    def at_least_one_name(params)
      return true if step_params(params).size > 0

      errors.add(:base, "Please add at least one contributor")
      false
    end

    def step_params(params)
      @step_params ||= ActionController::Parameters.new(params).
                        permit("#{step}_step" => { name: [] }).
                        fetch("#{step}_step", {}).
                        fetch("name", []).
                        select { |name| !name.strip.blank? }
    end
  end
end
