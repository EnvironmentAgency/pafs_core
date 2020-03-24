# frozen_string_literal: true

class AddFinancialYearToProject < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :project_end_financial_year, :integer
  end
end
