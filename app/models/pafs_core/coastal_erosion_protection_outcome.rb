# frozen_string_literal: true
module PafsCore
  class CoastalErosionProtectionOutcome < ActiveRecord::Base
    belongs_to :project

    validates :households_at_reduced_risk,
              :households_protected_from_loss_in_next_20_years,
              :households_protected_from_loss_in_20_percent_most_deprived,
              numericality: true,
              allow_blank: true
  end
end
