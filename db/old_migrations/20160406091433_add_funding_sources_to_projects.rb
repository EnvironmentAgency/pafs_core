# frozen_string_literal: true

class AddFundingSourcesToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :fcerm_gia, :boolean
    add_column :pafs_core_projects, :local_levy, :boolean
    add_column :pafs_core_projects, :internal_drainage_boards, :boolean
    add_column :pafs_core_projects, :public_contributions, :boolean
    add_column :pafs_core_projects, :public_contributor_names, :string
    add_column :pafs_core_projects, :private_contributions, :boolean
    add_column :pafs_core_projects, :private_contributor_names, :string
    add_column :pafs_core_projects, :other_ea_contributions, :boolean
    add_column :pafs_core_projects, :other_ea_contributor_names, :string
    add_column :pafs_core_projects, :growth_funding, :boolean
    add_column :pafs_core_projects, :not_yet_identified, :boolean
  end
end
