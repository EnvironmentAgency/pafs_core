# frozen_string_literal: true

class AddSubTypeToAreas < ActiveRecord::Migration
  def change
    add_column :pafs_core_areas, :sub_type, :string
  end
end
