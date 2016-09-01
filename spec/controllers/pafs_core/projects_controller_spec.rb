# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProjectsController, type: :controller do
  routes { PafsCore::Engine.routes }

  before(:each) do
    @user = FactoryGirl.create(:user)
    @country = FactoryGirl.create(:country, :with_full_hierarchy)
    @area = PafsCore::Area.last
    @user.user_areas.create(area_id: @area.id, primary: true)
    @project = PafsCore::Project.last
    allow(subject).to receive(:current_resource) { @user }
  end

  describe "GET index" do
    it "assigns @projects" do
      # project = FactoryGirl.create(:project)
      get :index
      expect(assigns(:projects)).to eq([@project])
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

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

  describe "GET submit" do
    it "renders the submit template" do
      get :submit, id: @project.to_param
      expect(response).to render_template("submit")
    end
  end

  describe "GET pipeline" do
    it "renders the pipeline template" do
      get :pipeline
      expect(response).to render_template("pipeline")
    end
  end

  # describe "GET reference_number" do
  #   before(:each) do
  #     @project = FactoryGirl.create(:project)
  #     get :reference_number, id: @project.to_param
  #   end
  #
  #   it "renders the reference_number template" do
  #     expect(response).to render_template("reference_number")
  #   end
  #
  #   it "assigns @project to the first step" do
  #     expect(assigns(:project)).to be_instance_of PafsCore::ProjectNameStep
  #   end
  # end

  describe "GET step" do
    it "assigns @project with the appropriate step class" do
      get :step, id: @project.to_param, step: "project_name"
      expect(assigns(:project)).to be_instance_of PafsCore::ProjectNameStep
    end

    it "renders the template specified by the selected step" do
      get :step, id: @project.to_param, step: "project_name"
      expect(response).to render_template "project_name"
    end

    # context "when getting the location step" do
    #   it "gets a set of results based on a search paramater" do
    #     get :step, id: @project.to_param, step: "location", q: "412121, 102121"
    #     expect(assigns(:results)).to eq([{northings: "102121", eastings: "412121"}])
    #   end
    # end
    #
    # context "when getting the map step" do
    #   it "gets the map centre based on benefit_area_centre" do
    #     @project.benefit_area_centre = %w(412121 102121)
    #     @project.project_location = %w(412121 102121)
    #     @project.save
    #     get :step, id: @project.to_param, step: "map"
    #     expect(assigns(:map_centre)).to eq([{northings: "102121", eastings: "412121"}])
    #   end
    # end

    # context "when step is disabled" do
    #   it "raises a not_found error" do
    #     expect { get :step, id: @project.to_param, step: "funding_values" }.
    #       to raise_error ActionController::RoutingError
    #   end
    # end
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

  describe "GET download_funding_calculator" do
    context "given a file has been stored previously" do
      let(:navigator) { double("navigator") }
      let(:step) { double("funding_calculator_step") }
      let(:data) { "This is the file data" }
      let(:filename) { "my_upload.xls" }
      let(:content_type) { "text/plain" }

      it "sends the file to the client" do
        expect(controller).to receive(:navigator) { navigator }
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
    context "given a file has been stored previously" do
      let(:navigator) { double("navigator") }
      let(:step) { double("funding_calculator_step") }
      let(:filename) { "my_upload.xls" }
      let(:content_type) { "text/plain" }

      it "deletes the funding calculator" do
        expect(controller).to receive(:navigator) { navigator }
        expect(navigator).to receive(:find_project_step).
          with(@project.to_param, :funding_calculator) { step }

        expect(step).to receive(:delete_calculator)

        get :delete_funding_calculator, id: @project.to_param
      end
    end
  end

  describe "GET download_benefit_area_file" do
    context "given a file has been stored previously" do
      let(:navigator) { double("navigator") }
      let(:step) { double("benefit_area_file_summary_step") }
      let(:data) { "This is the file data" }
      let(:filename) { "my_upload.xls" }
      let(:content_type) { "text/plain" }

      it "sends the file to the client" do
        expect(controller).to receive(:navigator) { navigator }
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
    context "given a file has been stored previously" do
      let(:navigator) { double("navigator") }
      let(:step) { double("benefit_area_file_summary_step") }
      let(:filename) { "my_upload.xls" }
      let(:content_type) { "text/plain" }

      it "deletes the funding benefit area file" do
        expect(controller).to receive(:navigator) { navigator }
        expect(navigator).to receive(:find_project_step).
          with(@project.to_param, :map) { step }

        expect(step).to receive(:delete_benefit_area_file)

        get :delete_benefit_area_file, id: @project.to_param
      end
    end
  end
end
