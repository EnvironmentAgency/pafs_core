# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::CalculatorParserService do
  let(:project) { FactoryBot.create(:project) }
  describe "#parse" do
    it "should parse the calculator and update the project values" do
      file_path = [Rails.root, "..", "fixtures", "calculator.xlsx"].join("/")
      file = File.open(file_path)

      subject.parse(file, project)

      expect(project.strategic_approach).to eq(true)
      expect(project.raw_partnership_funding_score).to eq(28.532857936396443)
      expect(project.adjusted_partnership_funding_score).to eq(29.44238044303537)
      expect(project.pv_whole_life_costs).to eq(25897.0)
      expect(project.pv_whole_life_benefits).to eq(1234)
      expect(project.duration_of_benefits).to eq(50)
      # FIXME: newer pf calc has these in different rows
      # expect(project.hectares_of_net_water_dependent_habitat_created).to eq(1)
      # expect(project.hectares_of_net_water_intertidal_habitat_created).to eq(1)
      # expect(project.kilometres_of_protected_river_improved).to eq(1)
    end

    it "should check that the calculator is an xlsx file" do
      file = Tempfile.new("tmp")

      expect { subject.parse(file, project) }.to raise_error("require an xlsx file")
      file.unlink
    end
  end

  describe "#binary_value" do
    it "should return the correct value" do
      expect(subject.binary_value("yes")).to eq true
      expect(subject.binary_value("YeS")).to eq true
      expect(subject.binary_value("No")).to eq false

      random_string = (0...10).map { ("a".."z").to_a[rand(26)] }.join
      expect(subject.binary_value(random_string)).to eq false
    end
  end
end
