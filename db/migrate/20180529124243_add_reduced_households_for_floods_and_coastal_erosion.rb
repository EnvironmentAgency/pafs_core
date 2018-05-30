class AddReducedHouseholdsForFloodsAndCoastalErosion < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :reduced_risk_of_households_for_floods,          :boolean, null: false, default: false
    add_column :pafs_core_projects, :reduced_risk_of_households_for_coastal_erosion, :boolean, null: false, default: false
  end
end
