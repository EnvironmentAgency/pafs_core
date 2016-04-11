# This migration comes from pafs_core (originally 20160407111007)
class AddEarliestStartToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :could_start_early, :boolean
    add_column :pafs_core_projects, :earliest_start_month, :integer
    add_column :pafs_core_projects, :earliest_start_year, :integer
  end
end
