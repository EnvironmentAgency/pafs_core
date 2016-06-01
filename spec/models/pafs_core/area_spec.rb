# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::Area, type: :model do
  context "Any Area" do
    describe "attributes" do
      area_levels = [
        {
          level: :country,
          parent_id: nil
        },
        {
          level: :ea_area,
          parent_id: 1
        },
        {
          level: :pso_area,
          parent_id: 1
        },
        {
          level: :rma_area,
          parent_id: 1
        },
      ]
      area = area_levels.sample
      subject { FactoryGirl.create(area[:level], parent_id: area[:parent_id]) }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :area_type }
      it { is_expected.to validate_inclusion_of(:area_type).in_array(PafsCore::Area::AREA_TYPES) }
    end
  end
  context "Country" do
    describe "attributes" do
      subject { FactoryGirl.create(:country) }

      it { is_expected.to_not validate_presence_of :parent_id }
      it { is_expected.to_not validate_presence_of :sub_type }
    end
  end
  context "sub-Country area" do
    describe "attributes" do
      area_levels = [:ea_area, :pso_area, :rma_area]
      subject { FactoryGirl.create(area_levels.sample, parent_id: 1) }

      it { is_expected.to validate_presence_of :parent_id }
      it { is_expected.to_not validate_presence_of :sub_type unless subject.area_type == "RMA"}
    end
  end
  context "RMA Area" do
    describe "sub type" do
      subject { FactoryGirl.create(:rma_area, parent_id: 1) }

      it { is_expected.to validate_presence_of :sub_type }
    end
  end

  context "Looking for visible projects" do
    let(:country) { FactoryGirl.create(:country, :with_full_hierarchy) }
    let(:ea_area_1) { country.children.first }
    let(:ea_area_2) { country.children.second }
    let(:pso_area_1) { ea_area_1.children.first }
    let(:pso_area_2) { ea_area_1.children.second}
    let(:pso_area_3) { ea_area_2.children.first }
    let(:rma_area_1) { pso_area_1.children.first }
    let(:rma_area_2) { pso_area_1.children.second}
    let(:rma_area_3) { pso_area_2.children.first}
    let(:rma_area_4) { pso_area_3.children.first }

    describe ".projects" do
      context "as a country" do
        it "should see the correct number of projects" do
          expect(country.projects.size).to eq(8)
        end
      end
      context "as an EA area" do
        it "should see the correct number of projects" do
          expect(ea_area_1.projects.size).to eq(4)
        end

        it "should not see another EA area's projects" do
          expect(ea_area_1.projects).to_not eq(ea_area_2.projects)
        end

        it "should not see shared projects from outside the EA area" do
          project = rma_area_4.projects.first
          rma_area_1.area_projects.create(project_id: project.id)

          expect(ea_area_1.projects).to_not include(project)
        end
      end
      context "as a PSO area" do
        it "should see the correct number of projects" do
          expect(pso_area_1.projects.size).to eq(2)
        end

        it "should not see another PSO area's projects" do
          expect(pso_area_1.projects).to_not eq(pso_area_2.projects)
        end

        it "should not see shared projects from outside the PSO area" do
          project = rma_area_3.projects.first
          rma_area_1.area_projects.create(project_id: project.id)

          expect(pso_area_1.projects).to_not include(project)
        end
      end
      context "as an RMA area" do
        it "should see the correct number of projects" do
          expect(rma_area_1.projects.size).to eq(1)
        end

        it "should not see another RMA area's projects" do
          expect(rma_area_1.projects).to_not eq(rma_area_2.projects)
        end

        it "should see another RMA's shared project" do
          project = rma_area_2.projects.first
          rma_area_1.area_projects.create(project_id: project.id)

          expect(rma_area_1.projects).to include(project)
        end
      end
    end
  end
end
