# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FloodProtectionOutcomesSummaryStep, type: :model do
  before(:each) do
    @project = FactoryBot.create(:project)
    @project.project_end_financial_year = 2022
    @project.fluvial_flooding = true
    @fpo1 = FactoryBot.create(:flood_protection_outcomes, financial_year: 2017, project_id: @project.id)
    @fpo2 = FactoryBot.create(:flood_protection_outcomes, financial_year: 2020, project_id: @project.id)
    @fpo3 = FactoryBot.create(:flood_protection_outcomes, financial_year: 2030, project_id: @project.id)
    @project.flood_protection_outcomes << @fpo1
    @project.flood_protection_outcomes << @fpo2
    @project.flood_protection_outcomes << @fpo3

    @project.save
  end

  describe "#current_flood_protection_outcomes" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    it "should only return flood_protection_outcomes from before the project end financial year" do
      expect(subject.current_flood_protection_outcomes).to include(@fpo1, @fpo2)
      expect(subject.current_flood_protection_outcomes).not_to include(@fpo3)
    end
  end

  describe "#update" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    it "should return true" do
      expect(subject.update({})).to eq true
    end
  end

  describe "#total_fpo_for" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    it "should return the correct totals for the three columns" do
      expect(subject.total_fpo_for(:households_at_reduced_risk)).to eq 200
      expect(subject.total_fpo_for(:moved_from_very_significant_and_significant_to_moderate_or_low)).to eq 100
      expect(subject.total_fpo_for(:households_protected_from_loss_in_20_percent_most_deprived)).to eq 50
    end
  end
end
