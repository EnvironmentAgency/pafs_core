class AddWfdToProjects < ActiveRecord::Migration
  def change
    change_table(:pafs_core_projects) do |t|
      t.boolean :improve_surface_or_groundwater
      t.float :improve_surface_or_groundwater_amount
      t.boolean :improve_river
      t.boolean :improve_spa_or_sac
      t.boolean :improve_sssi
      t.boolean :improve_hpi
      t.float :improve_habitat_amount
      t.float :improve_river_amount
      t.boolean :create_habitat
      t.float :create_habitat_amount
      t.boolean :remove_fish_barrier
      t.boolean :remove_eel_barrier
      t.float :fish_or_eel_amount
    end
  end
end
