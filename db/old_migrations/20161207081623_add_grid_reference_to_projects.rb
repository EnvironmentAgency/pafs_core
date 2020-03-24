# frozen_string_literal: true

class AddGridReferenceToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :grid_reference, :string
  end
end
