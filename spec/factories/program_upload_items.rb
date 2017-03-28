# frozen_string_literal: true
FactoryGirl.define do
  factory :program_upload_item_success, class: PafsCore::ProgramUploadItem do
    program_upload_id 1
    reference_number "ABC501E/000A/0001A"
    imported true

    factory :program_upload_item_fail do
      reference_number "ABC501E/000A/0112A"
      imported false
    end
  end
end
