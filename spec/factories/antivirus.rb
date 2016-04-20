# frozen_string_literal: true
require "clamav/client"
FactoryGirl.define do
  factory :virus_clear, class: ClamAV::SuccessResponse do
    initialize_with { new("path/to/clean_file.xls") }
  end

  factory :virus_found, class: ClamAV::VirusResponse do
    initialize_with { new("path/to/virus_file.xls", "HideousVirusName") }
  end

  factory :virus_error, class: ClamAV::ErrorResponse do
    initialize_with { new("A problem occurred") }
  end
end
