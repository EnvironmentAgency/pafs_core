# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FloodProtectionOutcomesStep, type: :model do
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

  describe "attributes" do
    subject { PafsCore::FloodProtectionOutcomesStep.new @project }
    it_behaves_like "a project step"

    it "validates that value C is smaller than B" do
      subject.flood_protection_outcomes.build(financial_year: 2020,
                                              households_at_reduced_risk: 100,
                                              moved_from_very_significant_and_significant_to_moderate_or_low: 50,
                                              households_protected_from_loss_in_20_percent_most_deprived: 100)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include
      "The number of households in the 20% most deprived areas (column C) must be lower than \
      or equal to the number of households moved from very significant \
      or significant to the moderate or low flood risk category (column B)."
    end

    it "validates that value B is smaller than A" do
      subject.flood_protection_outcomes.build(financial_year: 2020,
                                              households_at_reduced_risk: 100,
                                              moved_from_very_significant_and_significant_to_moderate_or_low: 200)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include
      "The number of households moved from very significant or significant to \
      the moderate or low flood risk category (column B) must be lower than or equal \
      to the number of households moved to a lower flood risk category (column A)."
    end

    it "validates that there is at least one A value" do
      @project.flood_protection_outcomes = []
      @project.save
      subject.flood_protection_outcomes.build(financial_year: 2020,
                                              households_at_reduced_risk: 0)

      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include
      "In the applicable year(s), tell us how many households moved to a lower flood \
      risk category (column A)."
    end

    it "validates that number of households is less than or equal to 1 million" do
      subject.flood_protection_outcomes.build(financial_year: 2020,
                                              households_at_reduced_risk: 1000001,
                                              moved_from_very_significant_and_significant_to_moderate_or_low: 1000001,
                                              households_protected_from_loss_in_20_percent_most_deprived: 1000001)
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include
      "The number of households at reduced risk must be less than or equal to 1 million."
      expect(subject.errors.messages[:base]).to include
      "The number of households moved from very significant and significant to moderate or low must be \
      less than or equal to 1 million."
      expect(subject.errors.messages[:base]).to include
      "The number of households protected from loss in the 20 percent most deprived must be \
      less than or equal to 1 million."
    end
  end

  describe "#update" do
    subject { PafsCore::FloodProtectionOutcomesStep.new @project }

    let(:params) {
      HashWithIndifferentAccess.new(
        { flood_protection_outcomes_step:
          { flood_protection_outcomes_attributes:
            [{ financial_year: 2020,
              households_at_reduced_risk: 2000,
              moved_from_very_significant_and_significant_to_moderate_or_low: 1000,
              households_protected_from_loss_in_20_percent_most_deprived: 500
            }]
          }
        }
      )
    }

    let(:error_params) {
      HashWithIndifferentAccess.new(
        { flood_protection_outcomes_step:
          { flood_protection_outcomes_attributes:
            [{ financial_year: 2020,
              households_at_reduced_risk: 1000,
              moved_from_very_significant_and_significant_to_moderate_or_low: 2000,
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
        expect { subject.update(error_params) }.not_to change { subject.flood_protection_outcomes.count }
      end
    end

    context "when params are valid" do
      it "saves the changes" do
        expect { subject.update(params) }.to change { subject.flood_protection_outcomes.count }.by(1)
        flood_protection_outcome = subject.flood_protection_outcomes.last
        expect(flood_protection_outcome.financial_year).to eq 2020
        expect(flood_protection_outcome.households_at_reduced_risk).to eq 2000
        expect(flood_protection_outcome.moved_from_very_significant_and_significant_to_moderate_or_low).to eq 1000
        expect(flood_protection_outcome.households_protected_from_loss_in_20_percent_most_deprived).to eq 500
      end

      it "returns true" do
        expect(subject.update(params)).to eq true
      end
    end
  end

  describe "#current_flood_protection_outcomes" do
    subject { PafsCore::FloodProtectionOutcomesStep.new @project }
    #subject.project.coastal_erosion_protection_outcomes << [@cepo1, @cepo2, @cepo3]
    it "should include the coastal erosion protection outcomes before the project end financial year" do
      expect(subject.current_flood_protection_outcomes).to include(@fpo1, @fpo2)
    end

    it "should not include the coastal erosion protection outcomes after the project end financial year" do
      expect(subject.current_flood_protection_outcomes).not_to include(@fpo3)
    end
  end

  describe "#before_view" do
    subject { PafsCore::FloodProtectionOutcomesStep.new @project }
    it "builds flood_protection_outcome records for any missing years" do
      # project_end_financial_year = 2022
      # funding_values records run until 2019
      # so expect 3 placeholders to be built for 2020, 2021 and 2022
      expect { subject.before_view({}) }.to change { subject.flood_protection_outcomes.length }.by(7)
    end
  end
end
