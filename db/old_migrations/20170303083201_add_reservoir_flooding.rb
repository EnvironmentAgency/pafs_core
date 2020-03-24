# frozen_string_literal: true

class AddReservoirFlooding < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :reservoir_flooding, :boolean
  end
end
