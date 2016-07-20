class ChangeProjectLocationDefaultOnProjects < ActiveRecord::Migration
  def change
    change_column :pafs_core_projects, :project_location, :text, array: true, default: []
  end
end
