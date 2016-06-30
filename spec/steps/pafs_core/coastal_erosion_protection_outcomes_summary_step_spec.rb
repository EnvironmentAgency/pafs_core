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

  describe "#update" do
    subject { PafsCore::CoastalErosionProtectionOutcomesSummaryStep.new @project }

    it "should update to :standard_of_protection" do
      expect(subject.step).to eq :coastal_erosion_protection_outcomes_summary
      subject.update({})
      expect(subject.step).to eq :standard_of_protection
    end
  end

  describe "#previous_step" do
    subject { PafsCore::CoastalErosionProtectionOutcomesSummaryStep.new @project }

    it "should return :coastal_erosion_protection_outcomes" do
      expect(subject.previous_step).to eq(:coastal_erosion_protection_outcomes)
    end
  end

  describe "#current_coastal_erosion_protection_outcomes" do
    subject { PafsCore::CoastalErosionProtectionOutcomesSummaryStep.new @project }

    it "should only return coastal_erosion_protection_outcomes from before the project end financial year" do
      expect(subject.current_coastal_erosion_protection_outcomes).to include(@cepo1, @cepo2)
      expect(subject.current_coastal_erosion_protection_outcomes).not_to include(@cepo3)
    end
  end

  describe "#step" do
    subject { PafsCore::CoastalErosionProtectionOutcomesSummaryStep.new @project }

    it "should return :coastal_erosion_protection_outcomes_summary" do
      expect(subject.step).to eq(:coastal_erosion_protection_outcomes_summary)
    end
  end

  describe "#disabled?" do
    subject { PafsCore::CoastalErosionProtectionOutcomesSummaryStep.new @project }

    context "when the project doesn't protect against coastal erosion" do
      it "should return true" do
        subject.project.coastal_erosion = false

        expect(subject.disabled?).to eq true
      end
    end

    context "when the project does protect against coastal erosion" do
      context "when the project end financial year isn't set" do
        it "should return true" do
          subject.project.project_end_financial_year = nil

          expect(subject.disabled?).to eq true
        end
      end

      context "when the project financial year is set" do
        it "should return false" do
          expect(subject.disabled?).to eq false
        end
      end
    end
  end

  describe "#completed?" do
    subject { PafsCore::CoastalErosionProtectionOutcomesSummaryStep.new @project }

    context "when project protects against coastal erosion" do
      context "when there are no current_coastal_erosion_protection_outcomes" do
        it "should return false" do
          subject.project.coastal_erosion_protection_outcomes = []

          expect(subject.completed?).to eq false
        end
      end
      context "when there are current_coastal_erosion_protection_outcomes" do
        it "should return true" do
          expect(subject.completed?).to eq true
        end
      end
    end

    context "when project does not protect against coastal erosion" do
      it "should return false" do
        subject.project.coastal_erosion = false

        expect(subject.completed?).to eq false
      end
    end
  end

  describe "#total_for" do
    subject { PafsCore::CoastalErosionProtectionOutcomesSummaryStep.new @project }

    it "should return the correct totals for the three columns" do
      expect(subject.total_for(:households_at_reduced_risk)).to eq 200
      expect(subject.total_for(:households_protected_from_loss_in_next_20_years)).to eq 100
      expect(subject.total_for(:households_protected_from_loss_in_20_percent_most_deprived)).to eq 50
    end
  end
end
