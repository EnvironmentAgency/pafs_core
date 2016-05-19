# This migration comes from pafs_core (originally 20160425084302)
class AddAttachmentFundingCalculatorToProjects < ActiveRecord::Migration
  def self.up
    add_column :pafs_core_projects, :funding_calculator_file_name, :string
    add_column :pafs_core_projects, :funding_calculator_content_type, :string
    add_column :pafs_core_projects, :funding_calculator_file_size, :integer
    add_column :pafs_core_projects, :funding_calculator_updated_at, :datetime
  end

  def self.down
    remove_column :pafs_core_projects, :funding_calculator_file_name
    remove_column :pafs_core_projects, :funding_calculator_content_type
    remove_column :pafs_core_projects, :funding_calculator_file_size
    remove_column :pafs_core_projects, :funding_calculator_updated_at
  end
end
