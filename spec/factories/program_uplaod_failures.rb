# frozen_string_literal: true
FactoryGirl.define do
  factory :program_upload_failure, class: PafsCore::ProgramUploadFailure do
    program_upload_item_id 1
    field_name "project_name"
    messages "Tell us the project name"
  end
end
