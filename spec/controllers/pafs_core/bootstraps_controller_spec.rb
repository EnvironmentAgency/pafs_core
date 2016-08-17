# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::BootstrapsController, type: :controller do
  routes { PafsCore::Engine.routes }

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
        post :funding, bootstrap: { fcerm_gia: true }
        expect(response).to render_template("funding")
      end

      it "assigns the :fcerm_gia value to the project in the response" do
        post :funding, bootstrap: { fcerm_gia: true }
        expect(assigns(:project).fcerm_gia).to eq true
      end
    end

    context "when :fcerm_gia is not present" do
      it "renders the 'new' template" do
        post :funding, bootstrap: { fcerm_gia: nil }
        expect(response).to render_template("new")
      end

      it "assigns a new project" do
        post :funding, bootstrap: { fcerm_gia: nil }
        expect(assigns(:project).new_record?).to eq true
      end

      it "sets an error message" do
        post :funding, bootstrap: { fcerm_gia: nil }
        expect(assigns(:project).errors[:fcerm_gia]).
          to include"^Tell us if you need Grant in Aid funding before 31 March 2021"
      end
    end
  end

  describe "POST create" do
    let(:params) { { bootstrap: { fcerm_gia: "true", local_levy: "false" } } }
    let(:false_params) { { bootstrap: { fcerm_gia: "false", local_levy: "false" } } }
    let(:no_fcerm_gia_params) { { bootstrap: { local_levy: "false" } } }
    let(:no_local_levy_params) { { bootstrap: { fcerm_gia: "true" } } }

    before(:each) do
      @pso = FactoryGirl.create(:pso_area, parent_id: 1, name: "PSO Essex")
      @rma = FactoryGirl.create(:rma_area, parent_id: @pso.id)
      @user = FactoryGirl.create(:user)
      @user.user_areas.create(area_id: @rma.id, primary: true)
      @nav = PafsCore::BootstrapNavigator.new(@user)
    end

    context "when :fcerm_gia and ::local_levy are valid" do
      context "when either :fcerm_gia or :local_levy are true" do
        it "creates a new project" do
          expect(subject).to receive(:navigator).twice { @nav }
          expect { post :create, params }.
            to change { PafsCore::Bootstrap.count }.by 1
        end

        it "sets the :fcerm_gia and :local_levy attributes accordingly" do
          expect(subject).to receive(:navigator).twice { @nav }
          post :create, params
          expect(assigns(:project).project.fcerm_gia).to eq true
          expect(assigns(:project).project.local_levy).to eq false
        end

        it "assigns @project" do
          expect(subject).to receive(:navigator).twice { @nav }
          post :create, params
          expect(assigns(:project).project).to eq PafsCore::Bootstrap.last
        end
      end

      context "when :fcerm_gia and :local_levy are false" do
        it "does not create a new project" do
          expect { post :create, false_params }.
            not_to change { PafsCore::Bootstrap.count }
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
          not_to change { PafsCore::Bootstrap.count }
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
          not_to change { PafsCore::Bootstrap.count }
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

  describe "GET step" do
    before(:each) { @project = FactoryGirl.create(:bootstrap) }

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
    before(:each) do
      @project = FactoryGirl.create(:bootstrap)
      @pso = FactoryGirl.create(:pso_area, parent_id: 1, name: "PSO Essex")
      @rma = FactoryGirl.create(:rma_area, parent_id: @pso.id)
      @user = FactoryGirl.create(:user)
      @user.user_areas.create(area_id: @rma.id, primary: true)
      @nav = PafsCore::BootstrapNavigator.new(@user)
    end

    it "assigns @project with appropriate step class" do
      get :step, id: @project.to_param, step: "project_name"
      expect(assigns(:project)).to be_instance_of PafsCore::ProjectNameStep
    end

    context "when given valid data to save" do
      it "updates the project" do
        patch :save, id: @project.to_param, step: "project_name",
          project_name_step: { name: "Wigwam" }
        expect(PafsCore::Bootstrap.find(@project.id).name).to eq "Wigwam"
      end

      it "redirects to the next step" do
        expect(subject).to receive(:navigator).exactly(3).times { @nav }
        patch :save, id: @project.to_param, step: "project_name",
          project_name_step: { name: "Haystack" }
        expect(response).to redirect_to bootstrap_step_path(id: @project.to_param, step: "project_type")
      end

      context "when the last step is saved" do
        it "redirects to the project summary page" do
          expect(subject).to receive(:navigator).exactly(4).times { @nav }
          patch :save, id: @project.to_param, step: "financial_year",
            financial_year_step: { project_end_financial_year: "2019" }
          proj = PafsCore::Project.last
          expect(response).to redirect_to project_path(id: proj.to_param)
        end
      end
    end

    context "when given invalid data to save" do
      it "does not update the project" do
        patch :save, id: @project.to_param, step: "project_type",
          project_type_step: { project_type: "1234" }
        expect(PafsCore::Bootstrap.find(@project.id).project_type).not_to eq "1234"
      end

      it "renders the template specified by the selected step" do
        patch :save, id: @project.to_param, step: "project_type",
          project_type_step: { project_type: "1234" }
        expect(response).to render_template("project_type")
      end
    end
  end
end
