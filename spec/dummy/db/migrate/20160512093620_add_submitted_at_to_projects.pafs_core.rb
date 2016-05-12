# This migration comes from pafs_core (originally 20160512093451)
class AddSubmittedAtToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :submitted_at, :datetime
  end
end
