# frozen_string_literal: true

class CreateUserAreas < ActiveRecord::Migration
  def change
    create_table :pafs_core_user_areas do |t|

      t.timestamps null: false
      t.integer :user_id, null: false, index: true
      t.integer :area_id, null: false, index: true
      t.boolean :primary, default: false
    end
  end
end
