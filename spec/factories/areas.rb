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
          2.times { FactoryGirl.create(:ea_area, parent_id: country.id) }
        end
      end

      trait :with_ea_and_pso_areas do
        after(:create) do |country|
          2.times { FactoryGirl.create(:ea_area, :with_pso_areas, parent_id: country.id) }
        end
      end

      trait :with_full_hierarchy do
        after(:create) do |country|
          2.times { FactoryGirl.create(:ea_area, :with_pso_and_rma_areas, parent_id: country.id) }
        end
      end

      trait :with_full_hierarchy_and_projects do
        after(:create) do |country|
          FactoryGirl.create(:ea_area, :with_pso_rma_areas_and_full_projects, parent_id: country.id)
        end
      end
    end

    factory :ea_area do
      area_type "EA Area"

      trait :with_pso_areas do
        after(:create) do |area|
          2.times { FactoryGirl.create(:pso_area, parent_id: area.id) }
        end
      end

      trait :with_pso_and_rma_areas do
        after(:create) do |area|
          2.times { FactoryGirl.create(:pso_area, :with_rma_areas, parent_id: area.id) }
        end
      end

      trait :with_pso_rma_areas_and_full_projects do
        after(:create) do |area|
          FactoryGirl.create(:pso_area, :with_rma_areas_and_projects, parent_id: area.id)
        end
      end
    end

    factory :pso_area do
      area_type "PSO Area"

      trait :with_rma_areas do
        after(:create) do |pso_area|
          2.times { FactoryGirl.create(:rma_area, :with_project, parent_id: pso_area.id) }
        end
      end

      trait :with_rma_areas_and_projects do
        after(:create) do |pso_area|
          FactoryGirl.create(:rma_area, :with_full_projects, parent_id: pso_area.id)
        end

        after(:create) do |pso_area|
          5.times do
            FactoryGirl.create(:full_project)
            project = PafsCore::Project.last
            pso_area.area_projects.create(project: project, owner: true)
            FactoryGirl.create(:coastal_erosion_protection_outcomes, financial_year: -1, project_id: project.id)
            FactoryGirl.create(:flood_protection_outcomes, financial_year: -1, project_id: project.id)
            FactoryGirl.create(:full_funding_values, financial_year: -1, project_id: project.id)
            (0..11).each do |n|
              year = 2016 + n
              FactoryGirl.create(:coastal_erosion_protection_outcomes, financial_year: year, project_id: project.id)
              FactoryGirl.create(:flood_protection_outcomes, financial_year: year, project_id: project.id)
              FactoryGirl.create(:full_funding_values, financial_year: year, project_id: project.id)
            end
          end
        end
      end
    end

    factory :rma_area do
      area_type "RMA"
      sub_type "Local Authority"

      trait :with_project do
        after(:create) do |rma_area|
          p = PafsCore::Project.create(
            name: "Project #{rma_area.name}",
            reference_number: PafsCore::ProjectService.generate_reference_number("TH"),
            version: 0
          )
          p.save

          rma_area.area_projects.create(project_id: p.id, owner: true)
        end
      end

      trait :with_full_projects do
        after(:create) do |rma_area|
          5.times do
            FactoryGirl.create(:full_project)
            project = PafsCore::Project.last
            rma_area.area_projects.create(project: project, owner: true)
            FactoryGirl.create(:coastal_erosion_protection_outcomes, financial_year: -1, project_id: project.id)
            FactoryGirl.create(:flood_protection_outcomes, financial_year: -1, project_id: project.id)
            FactoryGirl.create(:full_funding_values, financial_year: -1, project_id: project.id)
            (0..11).each do |n|
              year = 2016 + n
              FactoryGirl.create(:coastal_erosion_protection_outcomes, financial_year: year, project_id: project.id)
              FactoryGirl.create(:flood_protection_outcomes, financial_year: year, project_id: project.id)
              FactoryGirl.create(:full_funding_values, financial_year: year, project_id: project.id)
            end
          end
        end
      end
    end
  end
end
