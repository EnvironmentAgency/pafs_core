# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::BootstrapsController, type: :controller do
  routes { PafsCore::Engine.routes }

  describe "GET new" do
    it "creates a new bootstrap project" do
      expect { get :new }.to change { PafsCore::Bootstrap.count }.by 1
    end

    it "assigns @project to the new project" do
      get :new
      expect(assigns(:project)).not_to be_nil
      expect(assigns(:project).project).to eq PafsCore::Bootstrap.last
    end

    it "redirects to the first step" do
      get :new
      project = assigns(:project)
      expect(response).to redirect_to bootstrap_step_path(id: project.to_param, step: "project_name")
    end
  end

  describe "GET step" do
    before(:each) { @project = FactoryBot.create(:bootstrap) }

    it "assigns @project with the appropriate step class" do
      get :step, params: { id: @project.to_param, step: "project_name" }
      expect(assigns(:project)).to be_instance_of PafsCore::ProjectNameStep
    end

    it "renders the template specified by the selected step" do
      get :step, params: { id: @project.to_param, step: "project_name" }
      expect(response).to render_template "project_name"
    end
  end

  describe "PATCH save" do
    before(:each) do
      @pso = FactoryBot.create(:pso_area, parent_id: 1)
      @rma = FactoryBot.create(:rma_area, parent_id: @pso.id)
      @user = FactoryBot.create(:user)
      @project = FactoryBot.create(:bootstrap, creator: @user)
      @user.user_areas.create(area_id: @rma.id, primary: true)
      @nav = PafsCore::BootstrapNavigator.new(@user)

      allow(controller).to receive(:current_resource) { @user }
    end

    it "assigns @project with appropriate step class" do
      get :step, params: { id: @project.to_param, step: "project_name" }
      expect(assigns(:project)).to be_instance_of PafsCore::ProjectNameStep
    end

    context "when given valid data to save" do
      it "updates the project" do
        patch :save, params: { id: @project.to_param, step: "project_name", project_name_step: { name: "Wigwam" } }
        expect(PafsCore::Bootstrap.find(@project.id).name).to eq "Wigwam"
      end

      it "redirects to the next step" do
        expect(subject).to receive(:navigator).exactly(3).times { @nav }
        patch :save, params: { id: @project.to_param, step: "project_name", project_name_step: { name: "Haystack" } }
        expect(response).to redirect_to bootstrap_step_path(id: @project.to_param, step: "project_type")
      end

      context "when the last step is saved" do
        it "redirects to the project summary page" do
          expect(subject).to receive(:navigator).exactly(4).times { @nav }
          patch :save, params: { id: @project.to_param, step: "financial_year", financial_year_step: { project_end_financial_year: "2025" } }
          proj = PafsCore::Project.last
          expect(response).to redirect_to project_path(id: proj.to_param)
        end
      end
    end

    context "when given invalid data to save" do
      it "does not update the project" do
        patch :save, params: { id: @project.to_param, step: "project_type", project_type_step: { project_type: "1234" } }
        expect(PafsCore::Bootstrap.find(@project.id).project_type).not_to eq "1234"
      end

      it "renders the template specified by the selected step" do
        patch :save, params: { id: @project.to_param, step: "project_type", project_type_step: { project_type: "1234" } }
        expect(response).to render_template("project_type")
      end
    end
  end
end
