class AddSubmittedToPolToPafsCoreProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :pafs_core_projects, :submitted_to_pol, :datetime
    add_index :pafs_core_projects, :submitted_to_pol
  end
end
