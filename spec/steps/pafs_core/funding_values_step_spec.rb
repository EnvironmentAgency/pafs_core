# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FundingValuesStep, type: :model do
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

  describe "attributes" do
    subject { PafsCore::FundingValuesStep.new @project }
    it_behaves_like "a project step"

    it "validates that at least one value per column is selected" do
      subject.project.local_levy = true
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "Please enter a value for Local levy"
    end

    it "validates that positive values have been entered" do
      subject.funding_values.build(financial_year: 2023, fcerm_gia: -200_000)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "Values must be greater than or equal to zero"
    end

    it "validates that at least one funding source is present" do
      subject.project.fcerm_gia = nil
      expect(subject.valid?).to eq false
      expect(subject.errors.messages[:base]).to include "You must select at least one funding source first"
    end
  end

  describe "#update" do
    subject { PafsCore::FundingValuesStep.new @project }

    let(:params) {
      HashWithIndifferentAccess.new(
        { funding_values_step: {
            funding_values_attributes: [
              { financial_year: 2020, fcerm_gia: 500_000 },
            ]
          }
        }
      )
    }
    let(:error_params) {
      HashWithIndifferentAccess.new(
        { funding_values_step: {
            funding_values_attributes: [
              { financial_year: 2020, local_levy: nil },
            ]
          }
        }
      )
    }

    context "when params are invalid" do
      before(:each) { subject.project.update_attributes(local_levy: true) }

      it "returns false" do
        expect(subject.update(error_params)).to eq false
      end

      it "does not save the changes" do
        expect { subject.update(error_params) }.not_to change { subject.funding_values.count }
      end

      it "does not change the next step when validation fails" do
        expect(subject.step).to eq :funding_values
        subject.update(error_params)
        expect(subject.step).to eq :funding_values
      end
    end

    context "when params are valid" do
      it "saves the changes" do
        expect { subject.update(params) }.to change { subject.funding_values.count }.by(1)
        expect(subject.funding_values.last.financial_year).to eq 2020
        expect(subject.funding_values.last.fcerm_gia).to eq 500_000
      end

      it "returns true" do
        expect(subject.update(params)).to eq true
      end

      context "when js_enabled param is set" do
        it "updates the next step to :earliest_start" do
          params[:js_enabled] = "1"
          expect(subject.step).to eq :funding_values
          subject.update(params)
          expect(subject.step).to eq :earliest_start
        end
      end

      context "when js_enabled param is not set" do
        it "updates the next step to :funding_values_summary" do
          expect(subject.step).to eq :funding_values
          subject.update(params)
          expect(subject.step).to eq :funding_values_summary
        end
      end
    end

    context "when funding_values exist for years after the :project_end_financial_year" do
      it "destroys those funding_values records" do
        outside_values = FactoryGirl.create(:funding_values, project_id: @project.id, financial_year: 2021)
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
      outside_values = FactoryGirl.create(:funding_values, project_id: @project.id, financial_year: 2021)
      subject.project.funding_values << outside_values
      subject.project.project_end_financial_year = 2020
      subject.project.save
      subject.project.reload
      expect(subject.current_funding_values).not_to include outside_values
    end
  end

  describe "#previous_step" do
    subject { PafsCore::FundingValuesStep.new @project }
    it "should return :funding_sources" do
      expect(subject.previous_step).to eq :funding_sources
    end
  end

  describe "#before_view" do
    subject { PafsCore::FundingValuesStep.new @project }
    it "builds funding_value records for any missing years" do
      # project_end_financial_year = 2022
      # funding_values records run until 2019
      # so expect 3 placeholders to be built for 2020, 2021 and 2022
      expect { subject.before_view }.to change { subject.funding_values.length }.by(3)
    end
  end

  describe "#disabled?" do
    subject { PafsCore::FundingValuesStep.new @project }
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
end
