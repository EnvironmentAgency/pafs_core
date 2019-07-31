FactoryBot.define do
  factory :funding_contributor, class: 'PafsCore::FundingContributor' do
    name { "EnviroCo Ltd" }
    contributor_type { PafsCore::FundingSources::PUBLIC_CONTRIBUTIONS }
    funding_value
    amount { 1000 }
    secured { true }
    constrained { false }

    trait :public_contributor do
      contributor_type { PafsCore::FundingSources::PUBLIC_CONTRIBUTIONS }
    end

    trait :private_contributor do
      contributor_type { PafsCore::FundingSources::PRIVATE_CONTRIBUTIONS }
    end

    trait :other_ea_contributor do
      contributor_type { PafsCore::FundingSources::EA_CONTRIBUTIONS }
    end
  end
end
