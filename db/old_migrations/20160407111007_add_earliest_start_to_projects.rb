# frozen_string_literal: true

class AddEarliestStartToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :could_start_early, :boolean
    add_column :pafs_core_projects, :earliest_start_month, :integer
    add_column :pafs_core_projects, :earliest_start_year, :integer
  end
end
