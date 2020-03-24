# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:pafs_core_users) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.string :first_name, null: false, default: ""
      t.string :last_name, null: false, default: ""
      t.string :job_title

      # Uncomment below if timestamps were not included in your original model.
      t.timestamps null: false
      t.string     :invitation_token
      t.datetime   :invitation_created_at
      t.datetime   :invitation_sent_at
      t.datetime   :invitation_accepted_at
      t.integer    :invitation_limit
      t.references :invited_by, polymorphic: true
      t.integer    :invitations_count, default: 0
    end

    add_index :pafs_core_users, :email,                unique: true
    add_index :pafs_core_users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    add_index :pafs_core_users, :unlock_token,         unique: true
    add_index :pafs_core_users, :invitations_count
    add_index :pafs_core_users, :invitation_token, unique: true
    add_index :pafs_core_users, :invited_by_id
  end

end
