class CreatePafsCoreFundingContributors < ActiveRecord::Migration[4.2]
  def change
    create_table :pafs_core_funding_contributors do |t|
      t.string :name
      t.string :contributor_type
      t.integer :funding_value_id
      t.integer :amount, limit: 8
      t.boolean :secured, null: false, default: false
      t.boolean :constrained, null: false, default: false

      t.timestamps null: false
    end

    add_index :pafs_core_funding_contributors, :funding_value_id
    add_index :pafs_core_funding_contributors, :contributor_type
    add_index :pafs_core_funding_contributors, [:funding_value_id, :contributor_type], name: :funding_contributors_on_funding_value_id_and_type
  end
end
