# frozen_string_literal: true

class AddStatusToAsiteSubmissions < ActiveRecord::Migration
  def change
    add_column :pafs_core_asite_submissions, :status, :string, null: false, default: "created"
  end
end
