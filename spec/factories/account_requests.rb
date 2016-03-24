# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
FactoryGirl.define do
  factory :account_request, class: PafsCore::AccountRequest do
    first_name "Peter"
    last_name "Shilton"
    email "pete@example.com"
    organisation "Wessex Water"
    job_title "Windmill Researcher"
    telephone_number "0123456678"
  end
end
