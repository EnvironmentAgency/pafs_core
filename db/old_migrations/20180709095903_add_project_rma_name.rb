class AddProjectRmaName < ActiveRecord::Migration
  def change
    add_column :pafs_core_projects, :rma_name, :string, null: true

    PafsCore::Project.all.each do |project|
      unless project.areas.first.nil?
        project.update_attributes!(rma_name: project.areas.first.name)
      end
    end
  end
end
