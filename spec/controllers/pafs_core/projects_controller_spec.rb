# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProjectsController, type: :controller do
  routes { PafsCore::Engine.routes }

  before(:each) do
    @user = FactoryGirl.create(:user)
    @country = FactoryGirl.create(:country, :with_full_hierarchy)
    @area = PafsCore::Area.last
    @user.user_areas.create(area_id: @area.id, primary: true)
    # @project = PafsCore::Project.last
    @project = FactoryGirl.create(:project)
    @project.area_projects.create(area_id: @area.id)
    allow(subject).to receive(:current_resource) { @user }
  end

  # FIXME: strange error with Kaminari in test where .page is not
  # available on ActiveRecord::Relation for some reason
  # describe "GET index" do
  #   it "assigns @projects" do
  #     get :index
  #     expect(assigns(:projects)).to include(@project.reload)
  #   end
  #
  #   it "renders the index template for html responses" do
  #     get :index
  #     expect(response).to render_template("index")
  #   end
  # end

  describe "GET show" do
    it "assigns @project" do
      get :show, id: @project.to_param
      expect(assigns(:project)).to eq(@project)
    end

    it "renders the show template" do
      get :show, id: @project.to_param
      expect(response).to render_template("show")
    end
  end

  # describe "GET submit" do
  #   it "renders the submit template" do
  #     get :submit, id: @project.to_param
  #     expect(response).to render_template("submit")
  #   end
  # end

  describe "GET pipeline" do
    it "renders the pipeline template" do
      get :pipeline
      expect(response).to render_template("pipeline")
    end
  end

  describe "GET step" do
    it "assigns @project with the appropriate step class" do
      get :step, id: @project.to_param, step: "project_name"
      expect(assigns(:project)).to be_instance_of PafsCore::ProjectNameStep
    end

    it "renders the template specified by the selected step" do
      get :step, id: @project.to_param, step: "project_name"
      expect(response).to render_template "project_name"
    end
  end

  describe "PATCH save" do
    it "assigns @project with appropriate step class" do
      get :step, id: @project.to_param, step: "risks"
      expect(assigns(:project)).to be_instance_of PafsCore::RisksStep
    end

    context "when given valid data to save" do
      it "updates the project" do
        patch :save, id: @project.to_param, step: "project_name",
          project_name_step: { name: "Wigwam" }
        expect(PafsCore::Project.find(@project.id).name).to eq "Wigwam"
      end

      it "redirects to the next step or summary" do
        patch :save, id: @project.to_param, step: "project_name",
          project_name_step: { name: "Haystack" }
        expect(response).to redirect_to project_path(id: @project.to_param)
      end
    end

    context "when given invalid data to save" do
      it "does not update the project" do
        patch :save, id: @project.to_param, step: "project_type",
          project_type_step: { project_type: "1234" }
        expect(PafsCore::Project.find(@project.id).project_type).not_to eq "1234"
      end

      it "renders the template specified by the selected step" do
        patch :save, id: @project.to_param, step: "project_type",
          project_type_step: { project_type: "1234" }
        expect(response).to render_template("project_type")
      end
    end
  end
end
