class AddBootstrapRmaName < ActiveRecord::Migration
  def change
    add_column :pafs_core_bootstraps, :rma_name, :string, null: true

    PafsCore::Bootstrap.all.each do |bootstrap|
      bootstrap.update_attributes!(rma_name: bootstrap.creator.primary_area.name)
    end
  end
end
