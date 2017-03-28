# frozen_string_literal: true
FactoryGirl.define do
  factory :program_upload, class: PafsCore::ProgramUpload do
    filename "fcerm1_program.xslx"
    number_of_records 100
  end
end
