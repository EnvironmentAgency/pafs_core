# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::CoastalErosionProtectionOutcomesSummaryStep, type: :model do
  before(:each) do
    @project = FactoryGirl.create(:project)
    @project.project_end_financial_year = 2022
    @project.coastal_erosion = true
    @cepo1 = FactoryGirl.create(:coastal_erosion_protection_outcomes, financial_year: 2017, project_id: @project.id)
    @cepo2 = FactoryGirl.create(:coastal_erosion_protection_outcomes, financial_year: 2020, project_id: @project.id)
    @cepo3 = FactoryGirl.create(:coastal_erosion_protection_outcomes, financial_year: 2030, project_id: @project.id)
    @project.coastal_erosion_protection_outcomes << @cepo1
    @project.coastal_erosion_protection_outcomes << @cepo2
    @project.coastal_erosion_protection_outcomes << @cepo3

    @project.save
  end

  describe "#current_coastal_erosion_protection_outcomes" do
    subject { PafsCore::CoastalErosionProtectionOutcomesSummaryStep.new @project }

    it "should only return coastal_erosion_protection_outcomes from before the project end financial year" do
      expect(subject.current_coastal_erosion_protection_outcomes).to include(@cepo1, @cepo2)
      expect(subject.current_coastal_erosion_protection_outcomes).not_to include(@cepo3)
    end
  end

  describe "#update" do
    subject { PafsCore::CoastalErosionProtectionOutcomesSummaryStep.new @project }

    it "should return true" do
      expect(subject.update({})).to eq true
    end
  end

  describe "#total_for" do
    subject { PafsCore::CoastalErosionProtectionOutcomesSummaryStep.new @project }

    it "should return the correct totals for the three columns" do
      expect(subject.total_ce_for(:households_at_reduced_risk)).to eq 200
      expect(subject.total_ce_for(:households_protected_from_loss_in_next_20_years)).to eq 100
      expect(subject.total_ce_for(:households_protected_from_loss_in_20_percent_most_deprived)).to eq 50
    end
  end
end
