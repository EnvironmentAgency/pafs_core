# frozen_string_literal: true

class AddCalculatorFieldsToPafsCoreProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :strategic_approach,                                :boolean
    add_column :pafs_core_projects, :raw_partnership_funding_score,                     :float
    add_column :pafs_core_projects, :adjusted_partnership_funding_score,                :float
    add_column :pafs_core_projects, :pv_whole_life_costs,                               :float
    add_column :pafs_core_projects, :pv_whole_life_benefits,                            :float
    add_column :pafs_core_projects, :duration_of_benefits,                              :integer
    add_column :pafs_core_projects, :hectares_of_net_water_dependent_habitat_created,   :float
    add_column :pafs_core_projects, :hectares_of_net_water_intertidal_habitat_created,  :float
    add_column :pafs_core_projects, :kilometres_of_protected_river_improved,            :float
  end
end
