# frozen_string_literal: true

class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :pafs_core_users, :admin, :boolean, null: false, default: false
  end
end
