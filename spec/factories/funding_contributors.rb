FactoryBot.define do
  factory :funding_contributor, class: 'PafsCore::FundingContributor' do
    name { "EnviroCo Ltd" }
    funding_value
    amount { 1000 }
    secured { true }
    constrained { false }
  end
end
