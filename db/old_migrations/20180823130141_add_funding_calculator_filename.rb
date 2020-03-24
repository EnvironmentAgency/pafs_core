# frozen_string_literal: true

class AddFundingCalculatorFilename < ActiveRecord::Migration
  def change
    add_column :pafs_core_area_downloads, :funding_calculator_filename, :string
  end
end
