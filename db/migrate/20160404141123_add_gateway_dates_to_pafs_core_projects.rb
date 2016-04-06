class AddGatewayDatesToPafsCoreProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :start_outline_business_case_month, :integer
    add_column :pafs_core_projects, :start_outline_business_case_year, :integer
    add_column :pafs_core_projects, :award_contract_month, :integer
    add_column :pafs_core_projects, :award_contract_year, :integer
    add_column :pafs_core_projects, :start_construction_month, :integer
    add_column :pafs_core_projects, :start_construction_year, :integer
    add_column :pafs_core_projects, :ready_for_service_month, :integer
    add_column :pafs_core_projects, :ready_for_service_year, :integer
  end
end
