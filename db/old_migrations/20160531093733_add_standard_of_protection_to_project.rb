# frozen_string_literal: true

class AddStandardOfProtectionToProject < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :flood_protection_before, :integer
    add_column :pafs_core_projects, :flood_protection_after, :integer
    add_column :pafs_core_projects, :coastal_protection_before, :integer
    add_column :pafs_core_projects, :coastal_protection_after, :integer
  end
end
