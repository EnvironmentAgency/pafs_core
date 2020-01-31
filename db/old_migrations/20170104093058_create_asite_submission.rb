class CreateAsiteSubmission < ActiveRecord::Migration
  def change
    create_table :pafs_core_asite_submissions do |t|
      t.belongs_to :project
      t.datetime :email_sent_at, null: false
      t.datetime :confirmation_received_at
    end

    create_table :pafs_core_asite_files do |t|
      t.belongs_to :asite_submission
      t.string :filename, null: false
      t.string :checksum, null: false
    end
  end
end
