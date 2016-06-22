# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProjectsController, type: :controller do
  routes { PafsCore::Engine.routes }

  describe "GET index" do
    it "assigns @projects" do
      project = FactoryGirl.create(:project)
      get :index
      expect(assigns(:projects)).to eq([project])
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "GET show" do
    before(:each) { @project = FactoryGirl.create(:project) }

    it "assigns @project" do
      get :show, id: @project.to_param
      expect(assigns(:project)).to eq(@project)
    end

    it "renders the show template" do
      get :show, id: @project.to_param
      expect(response).to render_template("show")
    end
  end

  describe "GET new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template("new")
    end
  end

  describe "POST create" do
    before(:each) do
      @pso = FactoryGirl.create(:pso_area, parent_id: 1, name: "PSO Essex")
      @rma = FactoryGirl.create(:rma_area, parent_id: @pso.id)
      @user = FactoryGirl.create(:user)
      @user.user_areas.create(area_id: @rma.id, primary: true)
      @nav = PafsCore::ProjectNavigator.new(@user)
    end

    context "when starting within 6 years" do
      it "creates a new project" do
        expect(subject).to receive(:project_navigator) { @nav }
        expect { post :create, yes_or_no: "yes" }.to change { PafsCore::Project.count }.by 1
      end

      it "assigns @project" do
        expect(subject).to receive(:project_navigator) { @nav }
        post :create, yes_or_no: "yes"
        expect(assigns(:project).project).to eq PafsCore::Project.last
      end

      it "redirects to the reference number page" do
        expect(subject).to receive(:project_navigator) { @nav }
        post :create, yes_or_no: "yes"
        expect(response).to redirect_to reference_number_project_path(PafsCore::Project.last)
      end
    end

    context "when not starting within 6 years" do
      it "does not create a new project" do
        expect { post :create, yes_or_no: "no" }.not_to change { PafsCore::Project.count }
      end

      it "redirects to the pipeline page" do
        post :create, yes_or_no: "no"
        expect(response).to redirect_to(pipeline_projects_path)
      end
    end

    context "when not specifying start" do
      it "does not create a new project" do
        expect { post :create }.not_to change { PafsCore::Project.count }
      end

      it "sets a flash alert message" do
        post :create
        expect(flash[:alert]).to eq "Please choose Yes or No"
      end

      it "renders the :new template" do
        post :create
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET pipeline" do
    it "renders the pipeline template" do
      get :pipeline
      expect(response).to render_template("pipeline")
    end
  end

  describe "GET reference_number" do
    before(:each) do
      @project = FactoryGirl.create(:project)
      get :reference_number, id: @project.to_param
    end

    it "renders the reference_number template" do
      expect(response).to render_template("reference_number")
    end

    it "assigns @project to the first step" do
      expect(assigns(:project)).to be_instance_of PafsCore::ProjectNameStep
    end
  end

  describe "GET step" do
    before(:each) { @project = FactoryGirl.create(:project) }

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
    before(:each) { @project = FactoryGirl.create(:project) }

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

      it "redirects to the next step" do
        patch :save, id: @project.to_param, step: "project_name",
          project_name_step: { name: "Haystack" }
        expect(response).to redirect_to project_step_path(id: @project.to_param, step: "project_type")
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

    context "when only a single risk is selected" do
      before(:each) do
        patch :save, id: @project.to_param, step: "risks", risks_step: { tidal_flooding: "1" }
      end

      it "auto sets the main risk" do
        expect(PafsCore::Project.find_by(slug: @project.slug).main_risk).to eq "tidal_flooding"
      end

      it "jumps to the step after main_risk_step" do
        expect(response).to redirect_to project_step_path(id: @project.to_param, step: :households_benefiting)
      end
    end
  end

  describe "GET download_funding_calculator" do
    before(:each) { @project = FactoryGirl.create(:project) }

    context "given a file has been stored previously" do
      let(:navigator) { double("project_navigator") }
      let(:step) { double("funding_calculator_step") }
      let(:data) { "This is the file data" }
      let(:filename) { "my_upload.xls" }
      let(:content_type) { "text/plain" }

      it "sends the file to the client" do
        expect(controller).to receive(:project_navigator) { navigator }
        expect(navigator).to receive(:find_project_step).
          with(@project.to_param, :funding_calculator) { step }

        expect(step).to receive(:download) do |&block|
          block.call(data, filename, content_type)
        end

        expect(controller).to receive(:send_data).
          with(data, { filename: filename, type: content_type }) { controller.render nothing: true }

        get :download_funding_calculator, id: @project.to_param, step: "funding_calculator"
      end
    end
  end
end
