# frozen_string_literal: true

class AddSlugToPafsCoreProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :slug, :string, null: false, default: ""
    add_index :pafs_core_projects, :slug, unique: true
  end
end
