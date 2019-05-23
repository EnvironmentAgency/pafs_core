FactoryBot.define do
  factory :funding_contributor, class: 'PafsCore::FundingContributor' do
    name { "EnviroCo Ltd" }
    contributor_tyoe { PafsCore::FundingSources::PUBLIC_CONTRIBUTION }
    funding_value
    amount { 1000 }
    secured { true }
    constrained { false }

    trait :public_contributor do
      contributor_tyoe { PafsCore::FundingSources::PUBLIC_CONTRIBUTION }
    end
    trait :private_contributor do
      contributor_tyoe { PafsCore::FundingSources::PRIVATE_CONTRIBUTION }
    end
    trait :ea_contributor do
      contributor_tyoe { PafsCore::FundingSources::EA_CONTRIBUTION }
    end
  end
end
