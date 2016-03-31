# This migration comes from pafs_core (originally 20160329135958)
class AddFinancialYearToProject < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :project_end_financial_year, :integer
  end
end
