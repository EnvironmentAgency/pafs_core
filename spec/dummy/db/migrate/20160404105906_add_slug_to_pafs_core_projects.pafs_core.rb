# This migration comes from pafs_core (originally 20160404093808)
class AddSlugToPafsCoreProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :slug, :string, null: false, default: ""
    add_index :pafs_core_projects, :slug, unique: true
  end
end