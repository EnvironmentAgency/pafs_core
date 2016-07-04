# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::CoastalErosionProtectionOutcomesStep, type: :model do
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

  describe "attributes" do
    subject { PafsCore::CoastalErosionProtectionOutcomesStep.new @project }
    it_behaves_like "a project step"

    it "validates that value C is smaller than B" do
      subject.coastal_erosion_protection_outcomes.build(financial_year: 2020,
                                                        households_at_reduced_risk: 100,
                                                        households_protected_from_loss_in_next_20_years: 50,
                                                        households_protected_from_loss_in_20_percent_most_deprived: 100)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "C must be smaller than or equal to B"
    end

    it "validates that value B is smaller than A" do
      subject.coastal_erosion_protection_outcomes.build(financial_year: 2020,
                                                        households_at_reduced_risk: 100,
                                                        households_protected_from_loss_in_next_20_years: 200)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "B must be smaller than or equal to A"
    end

    it "validates that there is at least one A value" do
      @project.coastal_erosion_protection_outcomes = []
      @project.save
      subject.coastal_erosion_protection_outcomes.build(financial_year: 2020,
                                                        households_at_reduced_risk: 0)

      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "There must be at least one value in column A"
    end
  end

  describe "#update" do
    subject { PafsCore::CoastalErosionProtectionOutcomesStep.new @project }

    let(:params) {
      HashWithIndifferentAccess.new(
        { coastal_erosion_protection_outcomes_step:
          { coastal_erosion_protection_outcomes_attributes:
            [{ financial_year: 2020,
              households_at_reduced_risk: 2000,
              households_protected_from_loss_in_next_20_years: 1000,
              households_protected_from_loss_in_20_percent_most_deprived: 500
            }]
          }
        }
      )
    }

    let(:error_params) {
      HashWithIndifferentAccess.new(
        { coastal_erosion_protection_outcomes_step:
          { coastal_erosion_protection_outcomes_attributes:
            [{ financial_year: 2020,
              households_at_reduced_risk: 1000,
              households_protected_from_loss_in_next_20_years: 2000,
              households_protected_from_loss_in_20_percent_most_deprived: 5000
            }]
          }
        }
      )
    }

    context "when params are invalid" do
      it "returns false" do
        expect(subject.update(error_params)).to eq false
      end

      it "does not save the changes" do
        expect { subject.update(error_params) }.not_to change { subject.coastal_erosion_protection_outcomes.count }
      end

      it "does not change the next step when validation fails" do
        expect(subject.step).to eq :coastal_erosion_protection_outcomes
        subject.update(error_params)
        expect(subject.step).to eq :coastal_erosion_protection_outcomes
      end
    end

    context "when params are valid" do
      it "saves the changes" do
        expect { subject.update(params) }.to change { subject.coastal_erosion_protection_outcomes.count }.by(1)
        coastal_erosion_protection_outcome = subject.coastal_erosion_protection_outcomes.last
        expect(coastal_erosion_protection_outcome.financial_year).to eq 2020
        expect(coastal_erosion_protection_outcome.households_at_reduced_risk).to eq 2000
        expect(coastal_erosion_protection_outcome.households_protected_from_loss_in_next_20_years).to eq 1000
        expect(coastal_erosion_protection_outcome.households_protected_from_loss_in_20_percent_most_deprived).to eq 500
      end

      it "returns true" do
        expect(subject.update(params)).to eq true
      end

      context "when js_enabled param is set" do
        it "updates the next step to :coastal_erosion_protection_outcomes" do
          params[:js_enabled] = "1"
          @project.coastal_erosion = true
          expect(subject.step).to eq :coastal_erosion_protection_outcomes
          subject.update(params)
          expect(subject.step).to eq :standard_of_protection
        end
      end

      context "when js_enabled param is not set" do
        it "updates the next step to :flood_protection_outcomes_summary" do
          expect(subject.step).to eq :coastal_erosion_protection_outcomes
          subject.update(params)
          expect(subject.step).to eq :coastal_erosion_protection_outcomes_summary
        end
      end
    end
  end

  describe "#current_coastal_erosion_protection_outcomes" do
    subject { PafsCore::CoastalErosionProtectionOutcomesStep.new @project }
    #subject.project.coastal_erosion_protection_outcomes << [@cepo1, @cepo2, @cepo3]
    it "should include the coastal erosion protection outcomes before the project end financial year" do
      expect(subject.current_coastal_erosion_protection_outcomes).to include(@cepo1, @cepo2)
    end

    it "should not include the coastal erosion protection outcomes after the project end financial year" do
      expect(subject.current_coastal_erosion_protection_outcomes).not_to include(@cepo3)
    end
  end

  describe "#previous_step" do
    subject { PafsCore::CoastalErosionProtectionOutcomesStep.new @project }

    context "when project protects against flooding" do
      it "should return :flood_protection_outcomes" do
        subject.project.fluvial_flooding = true
        expect(subject.previous_step).to eq :flood_protection_outcomes
      end
    end

    context "when project doesn't protect against flooding" do
      it "should return :risks" do
        expect(subject.previous_step).to eq :risks
      end
    end
  end

  describe "#before_view" do
    subject { PafsCore::CoastalErosionProtectionOutcomesStep.new @project }
    it "builds coastal_erosion_protection_outcome records for any missing years" do
      # project_end_financial_year = 2022
      # funding_values records run until 2019
      # so expect 3 placeholders to be built for 2020, 2021 and 2022
      expect { subject.before_view }.to change { subject.coastal_erosion_protection_outcomes.length }.by(6)
    end
  end

  describe "#disabled?" do
    subject { PafsCore::CoastalErosionProtectionOutcomesStep.new @project }
    context "when the project does not protect any households" do
      it "returns true" do
        subject.project.project_type = "ENV_WITHOUT_HOUSEHOLDS"

        expect(subject.disabled?).to eq true
      end
    end
    context "when the project does not protect against coastal erosion" do
      it "returns true" do
        subject.project.coastal_erosion = false
        expect(subject.disabled?).to eq true
      end
    end
    context "when the project does protect against coastal erosion" do
      context "when there is no project end financial year" do
        it "returns true" do
          subject.project.project_end_financial_year = nil
          expect(subject.disabled?).to eq true
        end
      end
      context "when project end financial year is set" do
        it "returns false" do
          expect(subject.disabled?).to eq false
        end
      end
    end
  end

  describe "#completed?" do
    subject { PafsCore::CoastalErosionProtectionOutcomesStep.new @project }

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
end
