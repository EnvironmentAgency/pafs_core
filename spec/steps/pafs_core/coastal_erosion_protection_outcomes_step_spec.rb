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
      expect(subject.errors.messages[:base]).to include
      "The number of households in the 20% most deprived areas (column C) must be lower than or equal to the number of \
      households protected from loss within the next 20 years (column B)."
    end

    it "validates that value B is smaller than A" do
      subject.coastal_erosion_protection_outcomes.build(financial_year: 2020,
                                                        households_at_reduced_risk: 100,
                                                        households_protected_from_loss_in_next_20_years: 200)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include
      "The number of households protected from loss within the next 20 years (column B) must be lower than or equal \
      to the number of households at a reduced risk of coastal erosion (column A)."
    end

    it "validates that there is at least one A value" do
      @project.coastal_erosion_protection_outcomes = []
      @project.save
      subject.coastal_erosion_protection_outcomes.build(financial_year: 2020,
                                                        households_at_reduced_risk: 0)

      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include
      "In the applicable year(s), tell us how many households are at a reduced risk of coastal erosion."
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

  describe "#before_view" do
    subject { PafsCore::CoastalErosionProtectionOutcomesStep.new @project }
    it "builds coastal_erosion_protection_outcome records for any missing years" do
      # project_end_financial_year = 2022
      # funding_values records run until 2019
      # so expect 3 placeholders to be built for 2020, 2021 and 2022
      expect { subject.before_view }.to change { subject.coastal_erosion_protection_outcomes.length }.by(6)
    end
  end
end
