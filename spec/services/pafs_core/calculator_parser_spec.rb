# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::CalculatorParser do
  let(:project) { FactoryBot.create(:project) }
  let(:file_path) { File.join(Rails.root, '..', 'fixtures', 'calculator.xlsx') }
  let(:file) { File.open(file_path) }
  let(:invalid_file) { Tempfile.new('tmp') }

  describe "#parse" do
    it "should parse the calculator and update the project values" do
      described_class.parse(file, project)

      expect(project.strategic_approach).to eq(true)
      expect(project.raw_partnership_funding_score).to eq(59.30776823629341)
      expect(project.adjusted_partnership_funding_score).to eq(61.19828162789538)
      expect(project.pv_whole_life_costs).to eq(25_897.0)
      expect(project.pv_whole_life_benefits).to eq(1234)
      expect(project.duration_of_benefits).to eq(50)
      # FIXME: newer pf calc has these in different rows
      # expect(project.hectares_of_net_water_dependent_habitat_created).to eq(1)
      # expect(project.hectares_of_net_water_intertidal_habitat_created).to eq(1)
      # expect(project.kilometres_of_protected_river_improved).to eq(1)
    end

    it "should check that the calculator is an xlsx file" do
      expect { described_class.parse(invalid_file, project) }.to raise_error("require an xlsx file")
    end
  end

  describe "#binary_value" do
    let(:calculator) { Roo::Excelx.new(file.path) }

    subject { described_class.new(calculator, project) }

    it "should return the correct value" do
      expect(subject.binary_value("yes")).to eq true
      expect(subject.binary_value("YeS")).to eq true
      expect(subject.binary_value("No")).to eq false

      random_string = (0...10).map { ("a".."z").to_a[rand(26)] }.join
      expect(subject.binary_value(random_string)).to eq false
    end
  end
end
