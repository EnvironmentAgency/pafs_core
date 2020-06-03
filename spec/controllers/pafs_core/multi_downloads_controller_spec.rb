# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::MultiDownloadsController, type: :controller do
  routes { PafsCore::Engine.routes }

  let(:project) { create(:project, :pso_area) }
  let(:area) { project.areas.first }
  let(:user) { create(:user, area: area) }

  before(:each) do
    allow(subject).to receive(:current_resource) { user }
  end

  describe "GET index" do
    it "renders the template" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET proposals" do
    context "without a generated programme" do
      let!(:area_download) { create(:area_download, :failed, area: area) }

      it "should redirect back to the multi downloads page" do
        get :proposals
        expect(response).to redirect_to(multi_downloads_path)
      end
    end

    context "with a generated programme" do
      let!(:area_download) { create(:area_download, :ready, area: area) }
      let(:download_service) { double(:download_service, download_info: area_download, fcerm1_url: "/test_fcrm1.xlsx") }

      before do
        allow(PafsCore::AreaDownloadService).to receive(:new).and_return(download_service)
      end

      it "should redirect to the file download" do
        get :proposals
        expect(response).to redirect_to("/test_fcrm1.xlsx")
      end
    end
  end

  describe "GET funding_calculators" do
    context "without a generated programme" do
      let!(:area_download) { create(:area_download, :failed, area: area) }

      it "should redirect back to the multi downloads page" do
        get :funding_calculators
        expect(response).to redirect_to(multi_downloads_path)
      end
    end

    context "with a generated programme" do
      let!(:area_download) { create(:area_download, :ready, area: area) }
      let(:download_service) { double(:download_service, download_info: area_download, funding_calculators_url: "/fc.zip") }

      before do
        allow(PafsCore::AreaDownloadService).to receive(:new).and_return(download_service)
      end

      it "should redirect to the file download" do
        get :funding_calculators
        expect(response).to redirect_to("/fc.zip")
      end
    end
  end

  describe "GET benefit_areas" do
    context "without a generated programme" do
      let!(:area_download) { create(:area_download, :failed, area: area) }

      it "should redirect back to the multi downloads page" do
        get :benefit_areas
        expect(response).to redirect_to(multi_downloads_path)
      end
    end

    context "with a generated programme" do
      let!(:area_download) { create(:area_download, :ready, area: area) }
      let(:download_service) { double(:download_service, download_info: area_download, benefit_areas_url: "/ba.zip") }

      before do
        allow(PafsCore::AreaDownloadService).to receive(:new).and_return(download_service)
      end

      it "should redirect to the file download" do
        get :benefit_areas
        expect(response).to redirect_to("/ba.zip")
      end
    end
  end

  describe "GET moderations" do
    context "without a generated programme" do
      let!(:area_download) { create(:area_download, :failed, area: area) }

      it "should redirect back to the multi downloads page" do
        get :moderations
        expect(response).to redirect_to(multi_downloads_path)
      end
    end

    context "with a generated programme" do
      let!(:area_download) { create(:area_download, :ready, area: area) }
      let(:download_service) { double(:download_service, download_info: area_download, moderations_url: "/mo.zip") }

      before do
        allow(PafsCore::AreaDownloadService).to receive(:new).and_return(download_service)
      end

      it "should redirect to the file download" do
        get :moderations
        expect(response).to redirect_to("/mo.zip")
      end
    end
  end
end
