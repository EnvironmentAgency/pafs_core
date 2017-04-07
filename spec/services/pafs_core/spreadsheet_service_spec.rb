# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::SpreadsheetService do
  subject { PafsCore::SpreadsheetService.new }

  before(:each) do
    FactoryGirl.create(:country, :with_full_hierarchy_and_projects)
  end

  describe "#generate_csv" do
    it "should generate a CSV with the correct data" do
      project = PafsCore::Project.last

      generated_csv = subject.generate_csv(project)
      file_path = [Rails.root, "..", "fixtures", "test_projects.csv"].join("/")
      file = File.open(file_path)

      expect generated_csv == file
    end
  end

  describe "#generate_xlsx" do
    it "should generate an xlsx file with the correct data" do
      project = PafsCore::Project.last

      generated_xlsx = subject.generate_xlsx(project)
      file_path = [Rails.root, "..", "fixtures", "test_projects.xlsx"].join("/")
      file = File.open(file_path)

      expect generated_xlsx == file
    end
  end

  describe "#generate_multi_xlsx" do
    it "should generate an xlsx file with a row for each project" do
      # The area factory :country with trait :with_full_hierarchy_and_projects
      # creates a hierarchy and 5 projects which is what we need for our test,
      # but it doesn't create any users along the way. The ProjectService, and
      # particularly its search() method are dependent on the projects being
      # linked to the user, hence we create one here and attach it to the
      # projects via a UserArea record.
      rma_user = FactoryGirl.create(:user)
      rma_area = PafsCore::Area.rma_areas.last
      FactoryGirl.create(:user_area, user_id: rma_user.id, area_id: rma_area.id)

      ps = PafsCore::ProjectService.new(rma_user)

      puts "Search result count = #{ps.search.count}"
      generated_xlsx = subject.generate_multi_xlsx(ps.search)
    end
  end
end
