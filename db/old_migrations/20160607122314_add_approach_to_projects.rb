# frozen_string_literal: true

class AddApproachToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :approach, :string
  end
end
