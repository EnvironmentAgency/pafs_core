FactoryBot.define do
  factory :pafs_core_funding_contributor, class: 'PafsCore::FundingContributor' do
    name { "MyString" }
    funding_value_id { 1 }
    amount { 1 }
  end
end
