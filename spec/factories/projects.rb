# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

require File.join(PafsCore::Engine.root, 'spec', 'support', 'shapefile_upload')

FactoryBot.define do
  factory :project, class: PafsCore::Project do
    reference_number { PafsCore::ProjectService.generate_reference_number("TH") }
    version { 0 }
    private_contributions { private_contribution_names.any? }
    public_contributions { public_contribution_names.any? }
    other_ea_contributions { other_ea_contribution_names.any? }

    association :state, :draft
    creator factory: :user

    PafsCore::State::VALID_STATES.each do |valid_state|
      trait valid_state.to_sym do
        association :state, valid_state.to_sym
      end
    end

    trait :with_no_shapefile do
      benefit_area_file_name { nil }
    end

    trait :submitted_to_pol do
      association :state, :submitted
      submitted_to_pol { 5.minutes.ago }
    end

    trait :submission_failed do
      association :state, :submitted
      submitted_to_pol { nil }
    end

    trait :with_funding_values do
      create_funding_values { true }
    end

    transient do
      public_contribution_names { [] }
      private_contribution_names { [] }
      other_ea_contribution_names { [] }
      create_funding_values { false }
    end

    after(:create) do |project, builder|
      if builder.create_funding_values
        (2015..builder.project_end_financial_year || 2023).to_a.push(-1).each do |fy|
          create(
            :funding_value,
            public_contribution_names: builder.public_contribution_names,
            private_contribution_names: builder.private_contribution_names,
            other_ea_contribution_names: builder.other_ea_contribution_names,
            project: project,
            financial_year: fy,
          )
        end
      end
    end

    after(:create) do |project, builder|
      unless project.benefit_area_file_name.blank?
        ShapefileUpload::Upload.new(project, project.benefit_area_file_name).perform
      end
    end

    factory :full_project do
      reference_number { PafsCore::ProjectService.generate_reference_number("SO") }
      version { 0 }
      project_type { PafsCore::PROJECT_TYPES.first }
      project_end_financial_year { 2022 }
      start_outline_business_case_month { 2 }
      start_outline_business_case_year { 2012 }
      award_contract_month { 4 }
      award_contract_year { 2014 }
      start_construction_month { 5 }
      start_construction_year { 2015 }
      ready_for_service_month { 9 }
      ready_for_service_year { 2029 }
      fcerm_gia { true }
      local_levy { true }
      growth_funding { true }
      internal_drainage_boards { true }
      not_yet_identified { true }
      funding_sources_visited { true }
      could_start_early { true }
      earliest_start_month { 3 }
      earliest_start_year { 2017 }
      fluvial_flooding { true }
      sea_flooding { true }
      main_risk { "sea_flooding" }
      project_location { [457733, 221751] }
      project_location_zoom_level { 15 }
      benefit_area { "[[432123, 132453], [444444, 134444], [456543, 123432]]" }
      benefit_area_centre { [457733, 221751] }
      benefit_area_zoom_level { 23 }
      benefit_area_file_name { "shapefile.zip" }
      flood_protection_before { 1 }
      flood_protection_after { 2 }
      coastal_protection_before { 0 }
      coastal_protection_after { 3 }
      approach { "We will go left and then turn right for a bit" }
      improve_surface_or_groundwater { true }
      improve_surface_or_groundwater_amount { 50.25 }
      improve_river { true }
      improve_spa_or_sac { true }
      improve_sssi { true }
      improve_hpi { true }
      improve_habitat_amount { 1.23 }
      improve_river_amount { 21.7 }
      create_habitat { true }
      create_habitat_amount { 2.5 }
      remove_fish_barrier { true }
      remove_eel_barrier { true }
      fish_or_eel_amount { 22 }
      urgency_reason { "health_and_safety" }
      urgency_details { "This is the description" }
      parliamentary_constituency { "West Bromwich East" }
      region { "West Midlands" }
    end
  end
end
