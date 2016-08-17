# frozen_string_literal: true
module PafsCore
  class PrivateContributorsStep < BasicStep
    delegate :private_contributor_names,
             :private_contributor_names=,
             :other_ea_contributions?,
             to: :project

    validates :private_contributor_names, presence: { message: "^Tell us the private sector contributors." }

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:private_contributors_step).
        permit(:private_contributor_names)
    end
  end
end
