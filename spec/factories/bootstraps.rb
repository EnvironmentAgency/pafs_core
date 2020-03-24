# frozen_string_literal: true

FactoryBot.define do
  factory :bootstrap, class: PafsCore::Bootstrap do
    slug { SecureRandom.urlsafe_base64 }
    fcerm_gia { true }
    local_levy { false }
    name { "Chigley East Flood Defence" }
    project_type { "BRG" }
    project_end_financial_year { 2020 }
  end
end
