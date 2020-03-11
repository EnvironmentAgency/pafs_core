class AddCarbonToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :carbon_cost_build, :integer, limit: 8
    add_column :pafs_core_projects, :carbon_cost_operation, :integer, limit: 8
  end
end
