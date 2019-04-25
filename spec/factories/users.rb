# frozen_string_literal: true
FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user, class: PafsCore::User do
    first_name "Norville"
    last_name "Rogers"
    email
  end
end
