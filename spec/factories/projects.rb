# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
FactoryGirl.define do
  factory :project, class: PafsCore::Project do
    reference_number { PafsCore::ProjectService.generate_reference_number("TH") }
    version 0
  end
end
