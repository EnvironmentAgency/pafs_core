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
end
