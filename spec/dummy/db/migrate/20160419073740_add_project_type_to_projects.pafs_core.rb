# This migration comes from pafs_core (originally 20160419073315)
class AddProjectTypeToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :project_type, :string
  end
end
