class AddEnvironmentTypeToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :environmental_type, :string
  end
end
