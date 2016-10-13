# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::DownloadsController, type: :controller do
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
    it "renders the index template for html responses" do
      get :index, id: @project.to_param
      expect(response).to render_template("index")
    end

    it "renders an excel spreadsheet for xlsx requests" do
      get :index, id: @project.to_param, format: :xlsx
      expect(response.headers["Content-Type"]).to eq("application/xlsx")
    end

    it "renders a csv for csv requests" do
      get :index, id: @project.to_param, format: :csv
      expect(response.headers["Content-Type"]).to eq("text/csv")
    end
  end
end
