# frozen_string_literal: true
module PafsCore
  class OtherEaContributorsStep < BasicStep
    delegate :other_ea_contributor_names,
             :other_ea_contributor_names=,
             to: :project

    validates :other_ea_contributor_names,
      presence: { message: "^Tell us about the contributions from other Environment Agency functions or sources." }

  private
    def step_params(params)
      ActionController::Parameters.new(params).
        require(:other_ea_contributors_step).
        permit(:other_ea_contributor_names)
    end
  end
end
