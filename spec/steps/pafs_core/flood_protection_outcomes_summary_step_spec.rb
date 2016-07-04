# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FloodProtectionOutcomesSummaryStep, type: :model do
  before(:each) do
    @project = FactoryGirl.create(:project)
    @project.project_end_financial_year = 2022
    @project.fluvial_flooding = true
    @fpo1 = FactoryGirl.create(:flood_protection_outcomes, financial_year: 2017, project_id: @project.id)
    @fpo2 = FactoryGirl.create(:flood_protection_outcomes, financial_year: 2020, project_id: @project.id)
    @fpo3 = FactoryGirl.create(:flood_protection_outcomes, financial_year: 2030, project_id: @project.id)
    @project.flood_protection_outcomes << @fpo1
    @project.flood_protection_outcomes << @fpo2
    @project.flood_protection_outcomes << @fpo3

    @project.save
  end

  describe "#update" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    context "when the project protects against coastal erosion" do
      it "should update to :coastal_erosion_protection_outcomes" do
        subject.project.coastal_erosion = true
        expect(subject.step).to eq :flood_protection_outcomes_summary
        subject.update({})
        expect(subject.step).to eq :coastal_erosion_protection_outcomes
      end
    end

    context "when the project does not protect against coastal erosion" do
      it "should update to :standard_of_protection" do
        expect(subject.step).to eq :flood_protection_outcomes_summary
        subject.update({})
        expect(subject.step).to eq :standard_of_protection
      end
    end
  end

  describe "#previous_step" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    it "should return :flood_protection_outcomes" do
      expect(subject.previous_step).to eq(:flood_protection_outcomes)
    end
  end

  describe "#current_flood_protection_outcomes" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    it "should only return flood_protection_outcomes from before the project end financial year" do
      expect(subject.current_flood_protection_outcomes).to include(@fpo1, @fpo2)
      expect(subject.current_flood_protection_outcomes).not_to include(@fpo3)
    end
  end

  describe "#completed?" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    context "when project protects against flooding" do
      context "when there are no current_flood_protection_outcomes" do
        it "should return false" do
          subject.project.flood_protection_outcomes = []

          expect(subject.completed?).to eq false
        end
      end
      context "when there are current_flood_protection_outcomes" do
        it "should return true" do
          expect(subject.completed?).to eq true
        end
      end
    end

    context "when project does not protect against flooding" do
      it "should return false" do
        subject.project.fluvial_flooding = false

        expect(subject.completed?).to eq false
      end
    end
  end

  describe "#step" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    it "should return :flood_protection_outcomes_summary" do
      expect(subject.step).to eq(:flood_protection_outcomes_summary)
    end
  end

  describe "#disabled?" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    context "when the project doesn't protect against flooding" do
      it "should return true" do
        subject.project.fluvial_flooding = false

        expect(subject.disabled?).to eq true
      end
    end

    context "when the project does protect against flooding" do
      context "when the project does not protect any households" do
        it "returns true" do
          subject.project.project_type = "ENV_WITHOUT_HOUSEHOLDS"

          expect(subject.disabled?).to eq true
        end
      end
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

  describe "#total_for" do
    subject { PafsCore::FloodProtectionOutcomesSummaryStep.new @project }

    it "should return the correct totals for the three columns" do
      expect(subject.total_for(:households_at_reduced_risk)).to eq 200
      expect(subject.total_for(:moved_from_very_significant_and_significant_to_moderate_or_low)).to eq 100
      expect(subject.total_for(:households_protected_from_loss_in_20_percent_most_deprived)).to eq 50
    end
  end
end
