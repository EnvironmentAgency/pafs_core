# frozen_string_literal: true

class AddCreatorToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :creator_id, :integer, references: :users
  end
end
