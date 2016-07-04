# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FundingValuesSummaryStep, type: :model do
  before(:each) do
    @project = FactoryGirl.create(:project)
    @project.fcerm_gia = true
    @project.project_end_financial_year = 2022
    @fv1 = FactoryGirl.create(:previous_year, project_id: @project.id)
    @fv2 = FactoryGirl.create(:funding_values, project_id: @project.id, financial_year: 2016)
    @fv3 = FactoryGirl.create(:funding_values, project_id: @project.id, financial_year: 2017)
    @fv4 = FactoryGirl.create(:funding_values, project_id: @project.id, financial_year: 2018)
    @fv5 = FactoryGirl.create(:funding_values, project_id: @project.id, financial_year: 2019)
    @project.funding_values << @fv1
    @project.funding_values << @fv2
    @project.funding_values << @fv3
    @project.funding_values << @fv4
    @project.funding_values << @fv5

    @project.save
  end

  describe "#update" do
    subject { PafsCore::FundingValuesSummaryStep.new @project }

    it "updates the next step to :earliest_start" do
      expect(subject.step).to eq :funding_values_summary
      subject.update({})
      expect(subject.step).to eq :earliest_start
    end
  end

  describe "#selected_funding_sources" do
    subject { PafsCore::FundingValuesSummaryStep.new @project }

    it "returns which funding_sources have been selected" do
      expect(subject.selected_funding_sources).to eq [:fcerm_gia]
    end
  end

  describe "#previous_step" do
    subject { PafsCore::FundingValuesSummaryStep.new @project }
    it "should return :funding_values" do
      expect(subject.previous_step).to eq :funding_values
    end
  end

  describe "#current_funding_values" do
    subject { PafsCore::FundingValuesSummaryStep.new @project }
    it "returns funding_values without any that are later than the project_end_financial_year" do
      outside_values = FactoryGirl.create(:funding_values, project_id: @project.id, financial_year: 2021)
      subject.project.funding_values << outside_values
      subject.project.project_end_financial_year = 2020
      subject.project.save
      subject.project.reload
      expect(subject.current_funding_values).not_to include outside_values
    end
  end

  describe "#disabled?" do
    subject { PafsCore::FundingValuesSummaryStep.new @project }
    context "when there is no project end financial year" do
      it "returns true" do
        subject.project.project_end_financial_year = nil
        expect(subject.disabled?).to eq true
      end
    end
    context "when there are no funding sources" do
      it "returns true" do
        subject.project.fcerm_gia = false
        expect(subject.disabled?).to eq true
      end
    end
    context "when funding sources and project end financial year are set" do
      it "returns false" do
        expect(subject.disabled?).to eq false
      end
    end
  end

  describe "#total_for" do
    subject { PafsCore::FundingValuesSummaryStep.new @project }
    it "returns the sum of values for a funding source" do
      expect(subject.total_for(:fcerm_gia)).to eq 600_000
    end
  end

  describe "#grand_total" do
    subject { PafsCore::FundingValuesSummaryStep.new @project }
    it "returns the sum of values for all selected funding sources" do
      expect(subject.grand_total).to eq 600_000
    end
  end
end