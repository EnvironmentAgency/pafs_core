# frozen_string_literal: true
FactoryGirl.define do
  factory :user, class: OpenStruct do
    first_name "Norville"
    last_name "Rogers"
    email "shaggy@example.com"
  end
end
