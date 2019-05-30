# frozen_string_literal: true

module PafsCore
  class FundingContributorsStep < BasicStep
    include PafsCore::FundingSources
    include PafsCore::FundingValues

    validate :at_least_one_name

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
          fv.send(funding_source).create(name: name)
        end
      end
    end

    def update(params)
      setup_funding_values
      clean_unselected_funding_sources

      funding_values.reload
      delete_removed_contributors(params)
      create_new_contributors(params)
    end

    private

    def at_least_one_name
      return if current_funding_contributors.select{ |name| !name.strip.blank? }.size > 0

      errors.add(:base, "Please add at least one contributor")
    end

    def step_params(params)
      ActionController::Parameters.new(params).require("#{step}_step").permit(name: [])["name"]
    end
  end
end
