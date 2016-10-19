# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::DownloadsController, type: :controller do
  routes { PafsCore::Engine.routes }

  before(:each) do
    @user = FactoryGirl.create(:user)
    @country = FactoryGirl.create(:country, :with_full_hierarchy)
    @area = PafsCore::Area.rma_areas.last
    @user.user_areas.create(area_id: @area.id, primary: true)
    # @project = PafsCore::Project.last
    @project = FactoryGirl.create(:full_project)
    @project.area_projects.create(area_id: @area.id)
    allow(subject).to receive(:current_resource) { @user }
  end

  describe "GET index" do
    it "renders the index template for html responses" do
      get :index, id: @project.to_param
      expect(response).to render_template("index")
    end
  end

  describe "GET proposal" do
    it "renders an excel spreadsheet for xlsx requests" do
      get :proposal, id: @project.to_param, format: :xlsx
      expect(response.headers["Content-Type"]).to eq("application/xlsx")
    end

    it "renders a csv for csv requests" do
      get :proposal, id: @project.to_param, format: :csv
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end
  end

  describe "GET funding_calculator" do
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

        get :funding_calculator, id: @project.to_param, step: "funding_calculator"
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

  describe "GET benefit_area" do
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

        get :benefit_area, id: @project.to_param
      end
    end
  end

  describe "GET delete_benefit_area" do
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

        get :delete_benefit_area, id: @project.to_param
      end
    end
  end

  describe "GET moderation" do
    context "given the project is urgent" do
      let(:navigator) { double("navigator") }
      let(:presenter) { double("moderation_presenter") }
      let(:filename) { "moderation.txt" }
      let(:data) { "This is the file data" }
      let(:content_type) { "text/plain; charset=utf-8" }

      it "sends the file to the client" do
        expect(controller).to receive(:navigator) { navigator }
        expect(navigator).to receive(:find).
          with(@project.to_param) { @project }
        expect(PafsCore::ModerationPresenter).to receive(:new) { presenter }
        expect(presenter).to receive(:download) do |&block|
          block.call(data, filename, content_type)
        end

        expect(controller).to receive(:send_data).
          with(data, { filename: filename, type: content_type }) { controller.render nothing: true }

        get :moderation, id: @project.to_param
        expect(response.headers["Content-Type"]).to eq(content_type)
      end
    end
  end
end
