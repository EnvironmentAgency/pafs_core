class AddEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :pafs_core_users, :disabled, :boolean, null: false, default: false
    add_index :pafs_core_users, :disabled
  end
end
