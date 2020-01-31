class AddExtraGeoDataToPafsCoreProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :region, :string
    add_column :pafs_core_projects, :parliamentary_constituency, :string
  end
end
