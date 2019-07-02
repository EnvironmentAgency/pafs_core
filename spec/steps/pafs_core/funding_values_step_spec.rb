# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::FundingValuesStep, type: :model do
  before(:each) do
    @project = FactoryBot.create(:project)
    @project.fcerm_gia = true
    @project.project_end_financial_year = 2022
    @fv1 = FactoryBot.create(:funding_value, :blank, :previous_year, project: @project)
    @fv2 = FactoryBot.create(:funding_value, :blank, project: @project, financial_year: 2016)
    @fv3 = FactoryBot.create(:funding_value, :blank, project: @project, financial_year: 2017)
    @fv4 = FactoryBot.create(:funding_value, :blank, project: @project, financial_year: 2018)
    @fv5 = FactoryBot.create(:funding_value, :blank, project: @project, financial_year: 2019)
    @project.funding_values << @fv1
    @project.funding_values << @fv2
    @project.funding_values << @fv3
    @project.funding_values << @fv4
    @project.funding_values << @fv5

    @project.save
  end

  describe "#update" do
    subject { PafsCore::FundingValuesStep.new @project }

    let(:params) {
      HashWithIndifferentAccess.new(
        { funding_values_step: {
            funding_values_attributes: { 
              "0" => { financial_year: 2020, fcerm_gia: 500_000 },
            }
          }
        }
      )
    }

    it "saves the changes" do
      expect { subject.update(params) }.to change { subject.funding_values.count }.by(1)
      expect(subject.funding_values.last.financial_year).to eq 2020
      expect(subject.funding_values.last.fcerm_gia).to eq 500_000
    end

    it "returns true" do
      expect(subject.update(params)).to eq true
    end

    context "when funding_values exist for years after the :project_end_financial_year" do
      it "destroys those funding_values records" do
        outside_values = FactoryBot.create(:funding_value, project: @project, financial_year: 2021)
        subject.project.funding_values << outside_values
        subject.project.project_end_financial_year = 2020
        subject.project.save
        # adds new record and removes outside_values record
        expect(subject.update(params)).to eq true
        subject.project.reload
        expect(subject.funding_values).not_to include outside_values
      end
    end

    context "when funding value amounts exist for non-selected sources" do
      it "removes those amounts" do
        @fv2.update_attributes(local_levy: 2_000_000, growth_funding: 1_500)
        # adds new record and removes outside_values record
        expect(subject.update(params)).to eq true
        expect(@fv2.local_levy).to be_nil
        expect(@fv2.growth_funding).to be_nil
      end
    end
  end

  describe "#current_funding_values" do
    subject { PafsCore::FundingValuesStep.new @project }
    it "returns funding_values without any that are later than the project_end_financial_year" do
      outside_values = FactoryBot.create(:funding_value, project: @project, financial_year: 2021)
      subject.project.funding_values << outside_values
      subject.project.project_end_financial_year = 2020
      subject.project.save
      subject.project.reload
      expect(subject.current_funding_values).not_to include outside_values
    end
  end

  describe "#before_view" do
    subject { PafsCore::FundingValuesStep.new @project }
    it "builds funding_value records for any missing years" do
      # project_end_financial_year = 2022
      # funding_values records run until 2019
      # so expect 4 placeholders to be built for 2015, 2020, 2021 and 2022
      expect { subject.before_view({}) }.to change { subject.funding_values.length }.by(4)
    end
  end
end
