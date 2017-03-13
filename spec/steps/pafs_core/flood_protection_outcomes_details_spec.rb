# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FloodProtectionOutcomesSummaryStep, type: :model do
  before(:each) do
    @project = FactoryGirl.create(:project)
    @project.project_end_financial_year = 2022
    @project.fluvial_flooding = true
    @fpo1 = FactoryGirl.create(:flood_protection_outcomes, financial_year: 2017, project_id: @project.id)
    @fpo2 = FactoryGirl.create(:flood_protection_outcomes, financial_year: 2020, project_id: @project.id)
    @fpo1.households_at_reduced_risk = 100
    @fpo1.moved_from_very_significant_and_significant_to_moderate_or_low = 50
    @fpo1.households_protected_from_loss_in_20_percent_most_deprived = 25
    @fpo2.households_at_reduced_risk = 300
    @fpo2.moved_from_very_significant_and_significant_to_moderate_or_low = 150
    @fpo2.households_protected_from_loss_in_20_percent_most_deprived = 75
    @project.flood_protection_outcomes << @fpo1
    @project.flood_protection_outcomes << @fpo2

    @project.save
  end

  describe "when counts of protected households are available" do
    subject { @project }

    it "should return the correct totals for the three columns" do
      expect(subject.total_households_flood_protected_by_category(:households_at_reduced_risk)).to eq 400
      expect(subject.\
total_households_flood_protected_by_category(:moved_from_very_significant_and_significant_to_moderate_or_low)).to eq 200
      expect(subject.\
total_households_flood_protected_by_category(:households_protected_from_loss_in_20_percent_most_deprived)).to eq 100
    end
  end
end
