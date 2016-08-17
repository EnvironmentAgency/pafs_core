# frozen_string_literal: true
module PafsCore
  class PublicContributorsStep < BasicStep
    delegate :public_contributor_names,
             :public_contributor_names=,
             :private_contributions?,
             :other_ea_contributions?,
             to: :project

    validates :public_contributor_names, presence: { message: "^Tell us the public sector contributors." }

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:public_contributors_step).
        permit(:public_contributor_names)
    end
  end
end
