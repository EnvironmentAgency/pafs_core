# frozen_string_literal: true

class AddSeaWaterFlooding < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :sea_flooding, :boolean
  end
end
