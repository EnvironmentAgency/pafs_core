class RemoveEnvironmentalType < ActiveRecord::Migration
  def change
    remove_column :pafs_core_projects, :environmental_type
  end
end
