# frozen_string_literal: true

class CreateFundingValues < ActiveRecord::Migration
  def change
    create_table :pafs_core_funding_values do |t|
      t.references :project
      t.integer :financial_year, null: false
      t.integer :fcerm_gia, limit: 8
      t.integer :local_levy, limit: 8
      t.integer :internal_drainage_boards, limit: 8
      t.integer :public_contributions, limit: 8
      t.integer :private_contributions, limit: 8
      t.integer :other_ea_contributions, limit: 8
      t.integer :growth_funding, limit: 8
      t.integer :not_yet_identified, limit: 8
      t.integer :total, limit: 8, null: false, default: 0
    end
  end
end
