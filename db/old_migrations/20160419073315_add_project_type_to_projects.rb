# frozen_string_literal: true

class AddProjectTypeToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :project_type, :string
  end
end
