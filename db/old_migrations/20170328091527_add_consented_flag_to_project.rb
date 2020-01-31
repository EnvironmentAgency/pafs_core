class AddConsentedFlagToProject < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :consented, :boolean, null: false, default: false
  end
end
