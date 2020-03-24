# frozen_string_literal: true

class CreateFloodProtectionOutcomes < ActiveRecord::Migration
  def change
    create_table :pafs_core_flood_protection_outcomes do |t|
      t.references :project
      t.integer :financial_year, null: false
      t.integer :households_at_reduced_risk
      t.integer :moved_from_very_significant_and_significant_to_moderate_or_low
      t.integer :households_protected_from_loss_in_20_percent_most_deprived
    end
  end
end
