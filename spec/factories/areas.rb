# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
FactoryGirl.define do
  factory :area, class: PafsCore::Area do
    sequence :name do |n|
      "area #{n}"
    end

    factory :country do
      area_type "Country"

      trait :with_ea_areas do
        after(:create) do |country|
          (1..5).each { FactoryGirl.create(:ea_area, parent_id: country.id) }
        end
      end

      trait :with_ea_and_pso_areas do
        after(:create) do |country|
          (1..5).each { FactoryGirl.create(:ea_area, :with_pso_areas, parent_id: country.id) }
        end
      end

      trait :with_full_hierarchy do
        after(:create) do |country|
          (1..5).each { FactoryGirl.create(:ea_area, :with_pso_and_rma_areas, parent_id: country.id) }
        end
      end
    end

    factory :ea_area do
      area_type "EA Area"

      trait :with_pso_areas do
        after(:create) do |area|
          (1..5).each { FactoryGirl.create(:pso_area, parent_id: area.id) }
        end
      end

      trait :with_pso_and_rma_areas do
        after(:create) do |area|
          (1..5).each { FactoryGirl.create(:pso_area, :with_rma_areas, parent_id: area.id) }
        end
      end
    end

    factory :pso_area do
      area_type "PSO area"

      trait :with_rma_areas do
        after(:create) do |pso_area|
          (1..5).each { FactoryGirl.create(:rma_area, parent_id: pso_area.id) }
        end
      end
    end

    factory :rma_area do
      area_type "RMA"
    end
  end
end
