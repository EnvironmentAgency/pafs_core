# frozen_string_literal: true

class AddAttachmentBenefitAreaFileToProjects < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :benefit_area_file_name, :string
    add_column :pafs_core_projects, :benefit_area_content_type, :string
    add_column :pafs_core_projects, :benefit_area_file_size, :integer
    add_column :pafs_core_projects, :benefit_area_file_updated_at, :datetime
  end
end
