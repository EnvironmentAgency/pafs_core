# frozen_string_literal: true

class CreateState < ActiveRecord::Migration
  def change
    create_table :pafs_core_states do |t|
      t.belongs_to :project
      t.string :state, null: false, default: "draft"
      t.timestamps
    end
  end
end
