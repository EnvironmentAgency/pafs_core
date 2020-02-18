# frozen_string_literal: true

FactoryBot.define do
  factory :area_project, class: PafsCore::AreaProject do
    project
    area
  end
end

