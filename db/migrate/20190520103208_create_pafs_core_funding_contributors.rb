class CreatePafsCoreFundingContributors < ActiveRecord::Migration
  def change
    create_table :pafs_core_funding_contributors do |t|
      t.string :name
      t.integer :funding_value_id
      t.integer :amount

      t.timestamps null: false
    end
    add_index :pafs_core_funding_contributors, :funding_value_id
  end
end
