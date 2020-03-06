class AddConfidenceToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :confidence_homes_better_protected, :string, length: 20
    add_column :pafs_core_projects, :confidence_homes_by_gateway_four, :string, length: 20
    add_column :pafs_core_projects, :confidence_secured_partnership_funding, :string, length: 20
  end
end
