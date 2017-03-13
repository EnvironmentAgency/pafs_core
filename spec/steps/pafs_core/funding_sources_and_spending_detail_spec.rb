# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::Project, type: :model do
  before(:each) do
    @project = FactoryGirl.create(:project)
    @project.fcerm_gia = true
    @project.local_levy = true
    @project.public_contributions = true
    @project.private_contributions = true
    @project.other_ea_contributions = true
    @project.growth_funding = true
    @project.internal_drainage_boards = true
    @project.not_yet_identified = true
    @project.project_end_financial_year = 2022
    @fv1 = FactoryGirl.create(:funding_values, project_id: @project.id, financial_year: 2018)
    @fv2 = FactoryGirl.create(:funding_values, project_id: @project.id, financial_year: 2019)
    @fv1.fcerm_gia = 1000
    @fv1.local_levy = 1000
    @fv1.public_contributions = 1000
    @fv1.private_contributions = 1000
    @fv1.other_ea_contributions = 1000
    @fv1.growth_funding = 1000
    @fv1.internal_drainage_boards = 1000
    @fv1.not_yet_identified = 1000

    @fv2.fcerm_gia = 2000
    @fv2.local_levy = 2000
    @fv2.public_contributions = 2000
    @fv2.private_contributions = 2000
    @fv2.other_ea_contributions = 2000
    @fv2.growth_funding = 2000
    @fv2.internal_drainage_boards = 2000
    @fv2.not_yet_identified = 2000

    @project.funding_values << @fv1
    @project.funding_values << @fv2

    @project.save
  end

  describe "when spends are available" do
    subject { @project }

    it "should return the correct totals for the funding sources" do
      expect(subject.total_for_funding_source(:fcerm_gia)).to eq 3000
      expect(subject.total_for_funding_source(:local_levy)).to eq 3000
      expect(subject.total_for_funding_source(:public_contributions)).to eq 3000
      expect(subject.total_for_funding_source(:private_contributions)).to eq 3000
      expect(subject.total_for_funding_source(:growth_funding)).to eq 3000
      expect(subject.total_for_funding_source(:internal_drainage_boards)).to eq 3000
      expect(subject.total_for_funding_source(:not_yet_identified)).to eq 3000
    end
  end
end
