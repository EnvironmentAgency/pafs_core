# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::Project, type: :model do
  before(:each) do
    @project = FactoryGirl.create(:project)
    @project.project_end_financial_year = 2022
    @project.coastal_erosion = true
    @cepo1 = FactoryGirl.create(:coastal_erosion_protection_outcomes, financial_year: 2017, project_id: @project.id)
    @cepo2 = FactoryGirl.create(:coastal_erosion_protection_outcomes, financial_year: 2020, project_id: @project.id)
    @cepo1.households_at_reduced_risk = 100
    @cepo1.households_protected_from_loss_in_next_20_years = 50
    @cepo1.households_protected_from_loss_in_20_percent_most_deprived = 25
    @cepo2.households_at_reduced_risk = 300
    @cepo2.households_protected_from_loss_in_next_20_years = 150
    @cepo2.households_protected_from_loss_in_20_percent_most_deprived = 75
    @project.coastal_erosion_protection_outcomes << @cepo1
    @project.coastal_erosion_protection_outcomes << @cepo2

    @project.save
  end

  describe "when counts of protected households are available" do
    subject { @project }

    it "should return the correct totals for the three columns" do
      expect(subject.total_households_coastal_protected_by_category(:households_at_reduced_risk)).to eq 400
      expect(subject.\
total_households_coastal_protected_by_category(:households_protected_from_loss_in_next_20_years)).to eq 200
      expect(subject.\
total_households_coastal_protected_by_category(:households_protected_from_loss_in_20_percent_most_deprived)).to eq 100
    end
  end
end
