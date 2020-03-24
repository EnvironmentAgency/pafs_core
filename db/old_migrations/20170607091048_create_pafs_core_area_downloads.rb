# frozen_string_literal: true

class CreatePafsCoreAreaDownloads < ActiveRecord::Migration
  def change
    create_table :pafs_core_area_downloads do |t|
      t.references :area, index: true
      t.references :user
      t.datetime :requested_on
      t.integer :number_of_proposals
      t.string :fcerm1_filename
      t.string :benefit_areas_filename
      t.string :moderation_filename
      t.integer :number_of_proposals_with_moderation
      t.string :status, null: false, default: "empty"
      t.timestamps
    end
  end
end
