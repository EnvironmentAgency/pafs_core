# frozen_string_literal: true

class CreateCoastalErosionProtectionOutcomes < ActiveRecord::Migration
  def change
    create_table :pafs_core_coastal_erosion_protection_outcomes do |t|
      t.references :project
      t.integer :financial_year, null: false
      t.integer :households_at_reduced_risk
      t.integer :households_protected_from_loss_in_next_20_years
      t.integer :households_protected_from_loss_in_20_percent_most_deprived
    end
  end
end
