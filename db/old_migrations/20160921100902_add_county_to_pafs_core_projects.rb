class AddCountyToPafsCoreProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :county, :string
  end
end
