class CreateBootstrap < ActiveRecord::Migration
  def change
    create_table :pafs_core_bootstraps do |t|
      t.boolean :fcerm_gia
      t.boolean :local_levy
      t.string :name
      t.string :project_type
      t.integer :project_end_financial_year
      t.string :slug, null: false
      t.integer :creator_id, references: :users
      t.timestamps null: false
    end
    add_index :pafs_core_bootstraps, :slug, unique: true
  end
end
