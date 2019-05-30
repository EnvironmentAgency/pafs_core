# frozen_string_literal: true

module PafsCore
  class FundingContributorsStep < BasicStep
    delegate :funding_values, to: :project

    def funding_source
      :public_contributions
    end

    def funding_contributors
      @funding_contributors ||= project.funding_values.first.send(funding_source).map(&:name).tap do |contributors|
        return contributors if contributors.any?

        # We're initializing an array of names - so if there are none, we return
        # a new, empty name
        return ['']
      end
    end

    def funding_contributors_to_delete(params)
      @funding_contributors_to_delete ||= funding_contributors - step_params(params)
    end

    def delete_removed_contributors(params)
      funding_values.find_each do |fv|
        fv.send(funding_source).each do |funding_contributor|
          next unless funding_contributors_to_delete(params).include?(funding_contributor.name)

          funding_contributor.destroy!
        end
      end
    end

    def create_new_contributors(params)
      (step_params(params) - funding_contributors).each do |name|
        funding_values.find_each do |fv|
          fv.send(funding_source).create(name: name)
        end
      end
    end

    def update(params)
      delete_removed_contributors(params)
      create_new_contributors(params)
    end

    private

    def step_params(params)
      ActionController::Parameters.new(params).require("#{step}_step").permit(name: [])["name"]
    end
  end
end
