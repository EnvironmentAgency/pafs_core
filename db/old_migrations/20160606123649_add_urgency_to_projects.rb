# frozen_string_literal: true

class AddUrgencyToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :urgency_reason, :string
    add_column :pafs_core_projects, :urgency_details, :string
  end
end
