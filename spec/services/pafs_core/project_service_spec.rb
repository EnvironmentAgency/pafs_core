# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProjectService do
  before(:each) do
    @pso = FactoryGirl.create(:pso_area, parent_id: 1, name: "PSO Essex")
    @rma = FactoryGirl.create(:rma_area, parent_id: @pso.id)
    @user = FactoryGirl.create(:user)
    @user.user_areas.create(area_id: @rma.id, primary: true)
  end
  subject { PafsCore::ProjectService.new(@user) }

  describe "#new_project" do
    it "builds a new project model without saving to the database" do
      p = nil
      expect { p = subject.new_project }.to_not change { PafsCore::Project.count }
      expect(p).to be_a PafsCore::Project
      expect(p.reference_number).to start_with "AEC501E"
      expect(p.version).to eq(1)
      expect(p.creator_id).to eq(@user.id)
    end
  end

  describe "#create_project" do
    it "creates a new project and saves to the database" do
      p = nil
      expect { p = subject.create_project }.
        to change { PafsCore::Project.count }.by(1)

      expect(p).to be_a PafsCore::Project
      expect(p.reference_number).to_not be_nil
      expect(p.version).to eq(1)
      expect(p.creator_id).to eq(@user.id)
    end
  end

  describe "#find_project" do
    before(:each) do
      @project = subject.create_project
    end

    it "finds a project in the database by reference number" do
      expect(subject.find_project(@project.to_param)).to eq(@project)
    end

    it "raises ActiveRecord::RecordNotFound for an invalid reference_number" do
      expect { subject.find_project("123") }.
        to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#all_projects_for" do
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

    context "as a country" do
      it "should see the correct number of projects" do
        expect(subject.all_projects_for(country).size).to eq(8)
      end
    end
    context "as an EA area" do
      it "should see the correct number of projects" do
        expect(subject.all_projects_for(ea_area_1).size).to eq(4)
      end

      it "should not see another EA area's projects" do
        expect(subject.all_projects_for(ea_area_1)).to_not include(subject.all_projects_for(ea_area_2))
      end

      it "should not see shared projects from outside the EA area" do
        project = rma_area_4.projects.first
        rma_area_1.area_projects.create(project_id: project.id)

        expect(subject.all_projects_for(ea_area_1)).to_not include(project)
      end
    end
    context "as a PSO area" do
      it "should see the correct number of projects" do
        expect(subject.all_projects_for(pso_area_1).size).to eq(2)
      end

      it "should not see another PSO area's projects" do
        expect(subject.all_projects_for(pso_area_1)).to_not include(subject.all_projects_for(pso_area_2))
      end

      it "should not see shared projects from outside the PSO area" do
        project = rma_area_3.projects.first
        rma_area_1.area_projects.create(project_id: project.id)

        expect(subject.all_projects_for(pso_area_1)).to_not include(project)
      end
    end
    context "as an RMA area" do
      it "should see the correct number of projects" do
        expect(subject.all_projects_for(rma_area_1).size).to eq(1)
      end

      it "should not see another RMA area's projects" do
        expect(subject.all_projects_for(rma_area_1)).to_not include(subject.all_projects_for(rma_area_2))
      end

      it "should see another RMA's shared project" do
        project = rma_area_2.projects.first
        rma_area_1.area_projects.create(project_id: project.id)

        expect(subject.all_projects_for(rma_area_1)).to include(project)
      end
    end
  end

  describe "#area_ids_for_user" do
    let(:country) { FactoryGirl.create(:country, :with_full_hierarchy) }
    let(:ea_area_1) { country.children.first }
    let(:ea_area_2) { country.children.second }
    let(:pso_area_1) { ea_area_1.children.first }
    let(:pso_area_2) { ea_area_1.children.second }
    let(:pso_area_3) { ea_area_2.children.first }
    let(:pso_area_4) { ea_area_2.children.second }
    let(:rma_area_1) { pso_area_1.children.first }
    let(:rma_area_2) { pso_area_1.children.second }
    let(:rma_area_3) { pso_area_2.children.first }
    let(:rma_area_4) { pso_area_2.children.second }
    let(:rma_area_5) { pso_area_3.children.first }
    let(:rma_area_6) { pso_area_3.children.second }
    let(:rma_area_7) { pso_area_4.children.first }
    let(:rma_area_8) { pso_area_4.children.second }

    context "as a country" do
      it "should return the area :ids in my tree" do
        @user.user_areas.first.update_attributes(area_id: country.id)
        @user.touch
        areas = [country.id,
                 ea_area_1.id, ea_area_2.id,
                 pso_area_1.id, pso_area_2.id, pso_area_3.id, pso_area_4.id,
                 rma_area_1.id, rma_area_2.id, rma_area_3.id, rma_area_4.id,
                 rma_area_5.id, rma_area_6.id, rma_area_7.id, rma_area_8.id]

        expect(subject.area_ids_for_user(@user).sort).to eq areas.sort
      end
    end

    context "as an EA area" do
      it "should return the area :ids in my sub-tree" do
        @user.user_areas.first.update_attributes(area_id: ea_area_1.id)
        @user.touch
        areas = [ea_area_1.id,
                 pso_area_1.id, pso_area_2.id,
                 rma_area_1.id, rma_area_2.id, rma_area_3.id, rma_area_4.id]
        expect(subject.area_ids_for_user(@user).sort).to eq areas.sort
      end
    end

    context "as a PSO area" do
      it "should return the area :ids in my sub-tree" do
        @user.user_areas.first.update_attributes(area_id: pso_area_1.id)
        @user.touch
        areas = [pso_area_1.id,
                 rma_area_1.id, rma_area_2.id]
        expect(subject.area_ids_for_user(@user).sort).to eq areas.sort
      end
    end

    context "as an RMA area" do
      it "should return the area :ids in my sub-tree" do
        @user.user_areas.first.update_attributes(area_id: rma_area_1.id)
        @user.touch
        areas = [rma_area_1.id]
        expect(subject.area_ids_for_user(@user)).to eq areas
      end
    end
  end

  describe ".generate_reference_number" do
    it "returns a reference number in the correct format" do
      PafsCore::RFCC_CODES.each do |rfcc_code|
        ref = described_class.generate_reference_number(rfcc_code)
        expect(ref).to match /\A(AC|AE|AN|NO|NW|SN|SO|SW|TH|TR|WX|YO)C501E\/\d{3}A\/\d{3}A\z/
      end
    end
  end
end
