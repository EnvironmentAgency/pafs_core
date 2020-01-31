class AddUrgencyDetailsUpdatedAtToProject < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :urgency_details_updated_at, :datetime
  end
end
