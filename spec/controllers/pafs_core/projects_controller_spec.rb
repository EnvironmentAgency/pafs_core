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
      expect(assigns(:project)).not_to be_nil
      expect(response).to render_template("new")
    end
  end

  describe "POST funding" do
    context "when :fcerm_gia is present" do
      it "renders the 'funding' template" do
        post :funding, project: { fcerm_gia: true }
        expect(response).to render_template("funding")
      end

      it "assigns the :fcerm_gia value to the project in the response" do
        post :funding, project: { fcerm_gia: true }
        expect(assigns(:project).fcerm_gia).to eq true
      end
    end

    context "when :fcerm_gia is not present" do
      it "renders the 'new' template" do
        post :funding, project: { fcerm_gia: nil }
        expect(response).to render_template("new")
      end

      it "assigns a new project" do
        post :funding, project: { fcerm_gia: nil }
        expect(assigns(:project).new_record?).to eq true
      end

      it "sets an error message" do
        post :funding, project: { fcerm_gia: nil }
        expect(assigns(:project).errors[:fcerm_gia]).
          to include"^Tell us if you need Grant in Aid funding before 31 March 2021"
      end
    end
  end

  describe "POST create" do
    let(:params) { { project: { fcerm_gia: "true", local_levy: "false" } } }
    let(:false_params) { { project: { fcerm_gia: "false", local_levy: "false" } } }
    let(:no_fcerm_gia_params) { { project: { local_levy: "false" } } }
    let(:no_local_levy_params) { { project: { fcerm_gia: "true" } } }

    before(:each) do
      @pso = FactoryGirl.create(:pso_area, parent_id: 1, name: "PSO Essex")
      @rma = FactoryGirl.create(:rma_area, parent_id: @pso.id)
      @user = FactoryGirl.create(:user)
      @user.user_areas.create(area_id: @rma.id, primary: true)
      @nav = PafsCore::ProjectNavigator.new(@user)
    end

    context "when :fcerm_gia and ::local_levy are valid" do
      context "when either :fcerm_gia or :local_levy are true" do
        it "creates a new project" do
          expect(subject).to receive(:project_navigator).twice { @nav }
          expect { post :create, params }.
            to change { PafsCore::Project.count }.by 1
        end

        it "sets the :fcerm_gia and :local_levy attributes accordingly" do
          expect(subject).to receive(:project_navigator).twice { @nav }
          post :create, params
          expect(assigns(:project).project.fcerm_gia).to eq true
          expect(assigns(:project).project.local_levy).to eq false
        end

        it "assigns @project" do
          expect(subject).to receive(:project_navigator).twice { @nav }
          post :create, params
          expect(assigns(:project).project).to eq PafsCore::Project.last
        end

        it "redirects to the reference number page" do
          expect(subject).to receive(:project_navigator).twice { @nav }
          post :create, params
          expect(response).to redirect_to reference_number_project_path(PafsCore::Project.last)
        end
      end

      context "when :fcerm_gia and :local_levy are false" do
        it "does not create a new project" do
          expect { post :create, false_params }.
            not_to change { PafsCore::Project.count }
        end

        it "redirects to the pipeline page" do
          post :create, false_params
          expect(response).to redirect_to(pipeline_projects_path)
        end
      end
    end

    context "when :fcerm_gia is not present" do
      it "does not create a new project" do
        expect { post :create, no_fcerm_gia_params }.
          not_to change { PafsCore::Project.count }
      end

      it "renders the 'new' template" do
        post :create, no_fcerm_gia_params
        expect(response).to render_template("new")
      end

      it "assigns a new project" do
        post :create, no_fcerm_gia_params
        expect(assigns(:project).new_record?).to eq true
      end

      it "sets an error message" do
        post :create, no_fcerm_gia_params
        expect(assigns(:project).errors[:fcerm_gia]).
          to include"^Tell us if you need Grant in Aid funding before 31 March 2021"
      end
    end

    context "when :local_levy is not present" do
      it "does not create a new project" do
        expect { post :create, no_local_levy_params }.
          not_to change { PafsCore::Project.count }
      end

      it "renders the 'funding' template" do
        post :create, no_local_levy_params
        expect(response).to render_template("funding")
      end

      it "assigns a new project" do
        post :create, no_local_levy_params
        expect(assigns(:project).new_record?).to eq true
      end

      it "sets an error message" do
        post :create, no_local_levy_params
        expect(assigns(:project).errors[:local_levy]).
          to include"^Tell us if you need local levy funding before 31 March 2021"
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

    context "when getting the location step" do
      it "gets a set of results based on a search paramater" do
        get :step, id: @project.to_param, step: "location", q: "412121, 102121"
        expect(assigns(:results)).to eq([{northings: "102121", eastings: "412121"}])
      end
    end

    context "when getting the map step" do
      it "gets the map centre based on benefit_area_centre" do
        @project.benefit_area_centre = %w(412121 102121)
        @project.project_location = %w(412121 102121)
        @project.save
        get :step, id: @project.to_param, step: "map"
        expect(assigns(:map_centre)).to eq([{northings: "102121", eastings: "412121"}])
      end
    end

    context "when step is disabled" do
      it "raises a not_found error" do
        expect { get :step, id: @project.to_param, step: "funding_values" }.
          to raise_error ActionController::RoutingError
      end
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

      context "when the next step is :summary step" do
        it "redirects to the project summary page" do
          @project.update_attributes(funding_calculator_file_name: "peanuts.xsl")
          patch :save, id: @project.to_param, step: "funding_calculator_summary"
          expect(response).to redirect_to project_path(id: @project.to_param)
        end
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
        expect(response).to redirect_to project_step_path(id: @project.to_param, step: :flood_protection_outcomes)
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

  describe "GET delete_funding_calculator" do
    before(:each) { @project = FactoryGirl.create(:project) }

    context "given a file has been stored previously" do
      let(:navigator) { double("project_navigator") }
      let(:step) { double("funding_calculator_step") }
      let(:filename) { "my_upload.xls" }
      let(:content_type) { "text/plain" }

      it "deletes the funding calculator" do
        expect(controller).to receive(:project_navigator) { navigator }
        expect(navigator).to receive(:find_project_step).
          with(@project.to_param, :funding_calculator) { step }

        expect(step).to receive(:delete_calculator)

        get :delete_funding_calculator, id: @project.to_param
      end
    end
  end

  describe "GET download_benefit_area_file" do
    before(:each) { @project = FactoryGirl.create(:project) }

    context "given a file has been stored previously" do
      let(:navigator) { double("project_navigator") }
      let(:step) { double("benefit_area_file_summary_step") }
      let(:data) { "This is the file data" }
      let(:filename) { "my_upload.xls" }
      let(:content_type) { "text/plain" }

      it "sends the file to the client" do
        expect(controller).to receive(:project_navigator) { navigator }
        expect(navigator).to receive(:find_project_step).
          with(@project.to_param, :map) { step }

        expect(step).to receive(:download) do |&block|
          block.call(data, filename, content_type)
        end

        expect(controller).to receive(:send_data).
          with(data, { filename: filename, type: content_type }) { controller.render nothing: true }

        get :download_benefit_area_file, id: @project.to_param, step: "benefit_area_file_summary_step"
      end
    end
  end

  describe "GET delete_benefit_area_file" do
    before(:each) { @project = FactoryGirl.create(:project) }

    context "given a file has been stored previously" do
      let(:navigator) { double("project_navigator") }
      let(:step) { double("benefit_area_file_summary_step") }
      let(:filename) { "my_upload.xls" }
      let(:content_type) { "text/plain" }

      it "deletes the funding benefit area file" do
        expect(controller).to receive(:project_navigator) { navigator }
        expect(navigator).to receive(:find_project_step).
          with(@project.to_param, :map) { step }

        expect(step).to receive(:delete_benefit_area_file)

        get :delete_benefit_area_file, id: @project.to_param
      end
    end
  end
end
