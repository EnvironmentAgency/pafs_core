# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
FactoryBot.define do
  factory :user_area, class: PafsCore::UserArea do
    user
    area factory: :ea_area
    primary { true }
  end
end
