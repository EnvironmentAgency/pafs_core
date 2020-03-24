# frozen_string_literal: true

class CreateAreas < ActiveRecord::Migration
  def change
    create_table :pafs_core_areas do |t|
      t.string :name, index: true
      t.integer :parent_id
      t.string :area_type

      t.timestamps null: false
    end
  end
end
