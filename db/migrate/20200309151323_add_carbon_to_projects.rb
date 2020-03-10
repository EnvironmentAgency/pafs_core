class AddCarbonToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :carbon_cost_build, :integer
    add_column :pafs_core_projects, :carbon_cost_operation, :integer
  end
end
