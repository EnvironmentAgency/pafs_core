# frozen_string_literal: true

class CreateProgramUploads < ActiveRecord::Migration
  def change
    create_table :pafs_core_program_uploads do |t|
      t.string :filename, null: false
      t.integer :number_of_records, null: false
      t.timestamps
    end

    create_table :pafs_core_program_upload_items do |t|
      t.belongs_to :program_upload
      t.string :reference_number, null: false
      t.boolean :imported, null: false
      t.timestamps
    end

    create_table :pafs_core_program_upload_failures do |t|
      t.belongs_to :program_upload_item
      t.string :field_name, null: false
      t.string :messages, null: false
      t.timestamps
    end

    add_index :pafs_core_program_upload_items, :program_upload_id,
              name: "idx_program_upload_items"
    add_index :pafs_core_program_upload_failures, :program_upload_item_id,
              name: "idx_program_upload_failures"
  end
end
