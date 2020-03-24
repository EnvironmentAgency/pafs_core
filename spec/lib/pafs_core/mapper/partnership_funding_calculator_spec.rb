require "rails_helper"

RSpec.describe PafsCore::Mapper::PartnershipFundingCalculator do
  subject { described_class.new(calculator_file: File.open(calculator_file)) }

  let(:calculator_file) do
    File.join([Rails.root, "..", "fixtures", "calculators", "v8.xlsx"])
  end

  it "has a spreadsheet file" do
    expect(subject.calculator_file).to be_a(File)
  end

  describe "#attributes" do
    it "has a PV appraisal approach" do
      expect(subject.attributes[:pv_appraisal_approach]).to eql(12_345)
    end

    it "has a PV design and construction costs" do
      expect(subject.attributes[:pv_design_and_construction_costs]).to eql(12_341)
    end

    it "has a PV post-construction costs" do
      expect(subject.attributes[:pv_post_construction_costs]).to eql(1211)
    end

    it "has a PV local levy secured to data" do
      expect(subject.attributes[:pv_local_levy_secured_to_date]).to eql(200)
    end

    it "has a PV public contributions secured to date" do
      expect(subject.attributes[:pv_public_contributions_secured_to_date]).to eql(200)
    end

    it "has a PV private contributions secured to date" do
      expect(subject.attributes[:pv_private_contributions_secured_to_date]).to eql(200)
    end

    it "has a PV funding from other EA functions secured to date" do
      expect(subject.attributes[:pv_funding_from_other_ea_functions_sources_secured_to_date]).to eql(200)
    end

    it "has a PV Whole life benefit" do
      expect(subject.attributes[:pv_whole_life_benefits]).to eql(1234)
    end

    it "has QBOM220MB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:before][:most_deprived_20][:moderate_risk]).to eql(12)
    end

    it "has QBOM22140MB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:before][:most_deprived_21_40][:moderate_risk]).to eql(12)
    end

    it "has QBOM260MB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:before][:least_deprived_60][:moderate_risk]).to eql(12)
    end

    it "has QBOM220SB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:before][:most_deprived_20][:significant_risk]).to eql(22)
    end

    it "has QBOM22140SB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:before][:most_deprived_21_40][:significant_risk]).to eql(22)
    end

    it "has QBOM260SB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:before][:least_deprived_60][:significant_risk]).to eql(22)
    end

    it "has QBOM220VSB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:before][:most_deprived_20][:very_significant_risk]).to eql(11)
    end

    it "has QBOM22140VSB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:before][:most_deprived_21_40][:very_significant_risk]).to eql(11)
    end

    it "has QBOM260VSB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:before][:least_deprived_60][:very_significant_risk]).to eql(11)
    end

    it "has QBOM220MA" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:after][:most_deprived_20][:moderate_risk]).to eql(11)
    end

    it "has QBOM22140MA" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:after][:most_deprived_21_40][:moderate_risk]).to eql(11)
    end

    it "has QBOM260MA" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:after][:least_deprived_60][:moderate_risk]).to eql(11)
    end

    it "has QBOM220SA" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:after][:most_deprived_20][:significant_risk]).to eql(11)
    end

    it "has QBOM22140SA" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:after][:most_deprived_21_40][:significant_risk]).to eql(11)
    end

    it "has QBOM260SA" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:after][:least_deprived_60][:significant_risk]).to eql(11)
    end

    it "has QBOM220VSA" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:after][:most_deprived_20][:very_significant_risk]).to eql(10)
    end

    it "has QBOM22140VSA" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:after][:most_deprived_21_40][:very_significant_risk]).to eql(10)
    end

    it "has QBOM260VSA" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om2][:after][:least_deprived_60][:very_significant_risk]).to eql(10)
    end

    it "has QBOM320LTB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om3][:before_construction][:most_deprived_20][:long_term_loss]).to eql(10)
    end

    it "has QBOM32140LTB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om3][:before_construction][:most_deprived_21_40][:long_term_loss]).to eql(12)
    end
    it "has QBOM360LTB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om3][:before_construction][:least_deprived_60][:long_term_loss]).to eql(14)
    end

    it "has QBOM320MTB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om3][:before_construction][:most_deprived_20][:medium_term_loss]).to eql(11)
    end

    it "has QBOM32140MTB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om3][:before_construction][:most_deprived_21_40][:medium_term_loss]).to eql(13)
    end

    it "has QBOM360MTB" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om3][:before_construction][:least_deprived_60][:medium_term_loss]).to eql(15)
    end

    it "has QBOM4a" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om4][:hectares_of_net_water_dependent_habitat_created]).to eql(1.0)
    end

    it "has QBOM4b" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om4][:hectares_of_net_water_intertidal_habitat_created]).to eql(1.0)
    end

    it "has QBOM4c" do
      expect(subject.attributes[:qualifying_benefits_outcome_measures][:om4][:kilometres_of_protected_river_improved]).to eql(1.0)
    end
  end
end
