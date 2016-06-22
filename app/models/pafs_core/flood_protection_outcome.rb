# frozen_string_literal: true
module PafsCore
  class FloodProtectionOutcome < ActiveRecord::Base
    belongs_to :project

    validates :households_at_reduced_risk,
              :moved_from_very_significant_and_significant_to_moderate_or_low,
              :households_protected_from_loss_in_20_percent_most_deprived,
              numericality: true,
              allow_blank: true
  end
end
