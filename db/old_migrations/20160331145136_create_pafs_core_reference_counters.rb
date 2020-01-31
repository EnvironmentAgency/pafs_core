class CreatePafsCoreReferenceCounters < ActiveRecord::Migration
  def change
    create_table :pafs_core_reference_counters do |t|
      t.string :rfcc_code, null: false, default: ""
      t.integer :high_counter, null: false, default: 0
      t.integer :low_counter, null: false, default: 0
      t.timestamps null: false
    end
    add_index :pafs_core_reference_counters, :rfcc_code, unique: true
  end
end
