# frozen_string_literal: true

class AddPafsCoreAreaProjects < ActiveRecord::Migration
  def change
    create_table :pafs_core_area_projects do |t|
      t.integer :area_id, null: false
      t.integer :project_id, null: false
      t.boolean :owner, default: false

      t.timestamps null: false
    end

    add_index :pafs_core_area_projects, :area_id
    add_index :pafs_core_area_projects, :project_id
  end
end
