# frozen_string_literal: true

class CreatePafsCoreAccountRequests < ActiveRecord::Migration
  def change
    create_table :pafs_core_account_requests do |t|
      t.string :first_name, null: false, default: ""
      t.string :last_name, null: false, default: ""
      t.string :email, null: false, default: ""
      t.string :organisation, null: false, default: ""
      t.string :job_title
      t.string :telephone_number
      t.string :slug
      t.boolean :terms_accepted, null: false, default: false
      t.boolean :provisioned, null: false, default: false
      t.timestamps null: false
    end

    add_index :pafs_core_account_requests, :email, unique: true
    add_index :pafs_core_account_requests, :slug, unique: true
  end
end
