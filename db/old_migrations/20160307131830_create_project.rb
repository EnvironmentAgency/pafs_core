# frozen_string_literal: true

class CreateProject < ActiveRecord::Migration
  def change
    create_table :pafs_core_projects do |t|
      t.string :reference_number, null: false
      t.integer :version, null: false
      t.string :name

      t.timestamps null: false
    end

    add_index :pafs_core_projects, %i[reference_number version], unique: true
  end
end
