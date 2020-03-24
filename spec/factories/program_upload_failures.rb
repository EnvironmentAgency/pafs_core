# frozen_string_literal: true
FactoryBot.define do
  factory :program_upload_failure, class: PafsCore::ProgramUploadFailure do
    program_upload_item factory: :program_upload_item_fail
    field_name { "project_name" }
    messages { "Tell us the project name" }
  end
end
