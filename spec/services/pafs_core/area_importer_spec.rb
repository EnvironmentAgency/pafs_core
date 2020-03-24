# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::AreaImporter do
  describe "#import" do
    it "should successfully import the areas with correct data" do
      file_path = "#{Rails.root}/../fixtures/areas.csv"
      PafsCore::AreaImporter.new.import(file_path)
      areas = PafsCore::Area.all
      expect(areas.size).to eq(4)
    end

    it "should not import faulty data" do
      file_path = "#{Rails.root}/../fixtures/faulty_areas_data.csv"
      PafsCore::AreaImporter.new.import(file_path)
      areas = PafsCore::Area.all
      expect(areas.size).to eq(3)
    end
  end
end
