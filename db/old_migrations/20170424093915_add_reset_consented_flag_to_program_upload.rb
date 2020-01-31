class AddResetConsentedFlagToProgramUpload < ActiveRecord::Migration
  def change
    add_column :pafs_core_program_uploads, :reset_consented_flag, :boolean, null: false, default: false
  end
end
