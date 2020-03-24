# frozen_string_literal: true

class AddRisksStepToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :fluvial_flooding, :boolean
    add_column :pafs_core_projects, :tidal_flooding, :boolean
    add_column :pafs_core_projects, :groundwater_flooding, :boolean
    add_column :pafs_core_projects, :surface_water_flooding, :boolean
    add_column :pafs_core_projects, :coastal_erosion, :boolean
    add_column :pafs_core_projects, :main_risk, :string
  end
end
