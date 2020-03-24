# frozen_string_literal: true

class AddStatusToProgramUpload < ActiveRecord::Migration
  def change
    add_column :pafs_core_program_uploads, :status, :string, null: true, default: "new"
    add_index :pafs_core_program_uploads, :status, name: "pafs_core_upload_status"
  end
end
