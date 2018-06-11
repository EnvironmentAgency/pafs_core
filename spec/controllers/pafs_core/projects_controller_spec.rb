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
        expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'project-name')
      end
    end

    context 'user completes a section' do
      context 'saving the project name' do
        let(:params) do
          {
            id: @project.to_param,
            step: "project_name",
            project_name_step: {
              name: "Haystack"
            }
          }
        end

        it "redirects to the project name" do
          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'project-name')
        end
      end

      context 'saving the project type' do
        let(:params) do
          {
            project_type_step: {
              id: 4,
              project_type: "DEF"
            },
            commit: "Save and continue",
            id: @project.to_param,
            step: "project_type"
          }
        end

        it "redirects to the project type" do
          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'project-type')
        end
      end

      context 'saving the financial year' do
        let(:params) do
          {
            "financial_year_step": {
              "id": "4",
              "project_end_financial_year": "2018"
            },
            "commit": "Save and continue",
            "id": @project.to_param,
            "step": "financial_year"
          }
        end

        it "redirects to the financial year" do
          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'financial-year')
        end
      end

      context 'saving the location' do
        let(:params) do
          {
            commit: "Save and continue",
            id: @project.to_param,
            step: "benefit_area_file_summary"
          }
        end

        it "redirects to the location" do
          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'location')
        end
      end

      context 'saving the important dates' do
        let(:params) do
          {
            ready_for_service_date_step: {
              ready_for_service_month: 7,
              ready_for_service_year: "2022"
            },
            commit: "Save and continue",
            id: @project.to_param,
            step: "ready_for_service_date"
          }
        end

        it 'redirects to the important dates' do
          allow_any_instance_of(PafsCore::Project).to receive(:start_construction_year).and_return(2020)
          allow_any_instance_of(PafsCore::Project).to receive(:start_construction_month).and_return(8)

          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'key-dates')
        end
      end

      context 'saving the funding source' do
        let(:step_params) do
          {
            funding_sources_step: {
              fcerm_gia: "1",
              local_levy: "1",
            },
            commit: "Save and continue",
            id: @project.to_param,
            step: "funding_sources"
          }
        end

        let(:params) do
          {
            funding_values_step: {
              funding_values_attributes: {
                "0": {
                  financial_year: first_year.financial_year,
                  id:             first_year.id,
                  fcerm_gia:      first_year.fcerm_gia,
                  local_levy:     first_year.local_levy
                },
                "1": {
                  financial_year: second_year.financial_year,
                  id:             second_year.id,
                  fcerm_gia:      second_year.fcerm_gia,
                  local_levy:     second_year.local_levy
                },
                "2": {
                  financial_year: third_year.financial_year,
                  id:             third_year.id,
                  fcerm_gia:      third_year.fcerm_gia,
                  local_levy:     third_year.local_levy
                },
                "3": {
                  financial_year: fourth_year.financial_year,
                  id:             fourth_year.id,
                  fcerm_gia:      fourth_year.fcerm_gia,
                  local_levy:     fourth_year.local_levy
                },
                "4": {
                  financial_year: fifth_year.financial_year,
                  id:             fifth_year.id,
                  fcerm_gia:      fifth_year.fcerm_gia,
                  local_levy:     fifth_year.local_levy
                }
              }
            },
            js_enabled: "1",
            commit: "Save and continue",
            id: @project.to_param,
            step: "funding_values"
          }
        end

        let(:first_year) do
          @project.funding_values.create(
            financial_year: "-1",
            fcerm_gia: "10",
            local_levy: "20"
          )
        end

        let(:second_year) do
          @project.funding_values.create(
            financial_year: "2015",
            fcerm_gia: "",
            local_levy: ""
          )
        end

        let(:third_year) do
          @project.funding_values.create(
            financial_year: "2016",
            fcerm_gia: "",
            local_levy: ""
          )
        end

        let(:fourth_year) do
          @project.funding_values.create(
            financial_year: "2017",
            fcerm_gia: "",
            local_levy: ""
          )
        end

        let(:fifth_year) do
          @project.funding_values.create(
            financial_year: "2018",
            fcerm_gia: "",
            local_levy: ""
          )
        end

        before(:each) do
          patch :save, step_params
        end

        it 'redirects to the funding sources' do
          allow_any_instance_of(PafsCore::Project).to receive(:project_end_financial_year).and_return(2020)

          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'funding-sources')
        end
      end

      context 'saving the earliest start' do
        let(:params) do
          {
            earliest_date_step: {
              earliest_start_month: "2",
              earliest_start_year: "2025"
            },
            commit: "Save and continue",
            id: @project.to_param,
            step: "earliest_date"
          }
        end

        it 'redirects to the earliest date' do
          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'earliest-start')
        end
      end

      context 'saving the risks' do
        let(:first_flood_project_outcome) do
          @project.flood_protection_outcomes.create(
            financial_year: '-1',
            households_at_reduced_risk: '',
            moved_from_very_significant_and_significant_to_moderate_or_low: '',
            households_protected_from_loss_in_20_percent_most_deprived: ''
          )
        end

        let(:second_flood_project_outcome) do
          @project.flood_protection_outcomes.create(
            financial_year: '2015',
            households_at_reduced_risk: '',
            moved_from_very_significant_and_significant_to_moderate_or_low: '',
            households_protected_from_loss_in_20_percent_most_deprived: ''
          )
        end

        let(:third_flood_project_outcome) do
          @project.flood_protection_outcomes.create(
            financial_year: '2016',
            households_at_reduced_risk: '',
            moved_from_very_significant_and_significant_to_moderate_or_low: '',
            households_protected_from_loss_in_20_percent_most_deprived: ''
          )
        end

        let(:fourth_flood_project_outcome) do
          @project.flood_protection_outcomes.create(
            financial_year: '2017',
            households_at_reduced_risk: '',
            moved_from_very_significant_and_significant_to_moderate_or_low: '',
            households_protected_from_loss_in_20_percent_most_deprived: ''
          )
        end

        let(:fifth_flood_project_outcome) do
          @project.flood_protection_outcomes.create(
            financial_year: '2018',
            households_at_reduced_risk: '',
            moved_from_very_significant_and_significant_to_moderate_or_low: '',
            households_protected_from_loss_in_20_percent_most_deprived: ''
          )
        end

        let(:params) do
          {
            flood_protection_outcomes_step: {
              reduced_risk_of_households_for_floods: "1",
              flood_protection_outcomes_attributes: {
                '0': {
                  financial_year: first_flood_project_outcome.financial_year,
                  id: first_flood_project_outcome.id,
                  households_at_reduced_risk: first_flood_project_outcome.households_at_reduced_risk,
                  moved_from_very_significant_and_significant_to_moderate_or_low: first_flood_project_outcome.moved_from_very_significant_and_significant_to_moderate_or_low,
                  households_protected_from_loss_in_20_percent_most_deprived: first_flood_project_outcome.households_protected_from_loss_in_20_percent_most_deprived
                },
                '1': {
                  financial_year: second_flood_project_outcome.financial_year,
                  id: second_flood_project_outcome.id,
                  households_at_reduced_risk: second_flood_project_outcome.households_at_reduced_risk,
                  moved_from_very_significant_and_significant_to_moderate_or_low: second_flood_project_outcome.moved_from_very_significant_and_significant_to_moderate_or_low,
                  households_protected_from_loss_in_20_percent_most_deprived: second_flood_project_outcome.households_protected_from_loss_in_20_percent_most_deprived
                },
                '2': {
                  financial_year: third_flood_project_outcome.financial_year,
                  id: third_flood_project_outcome.id,
                  households_at_reduced_risk: third_flood_project_outcome.households_at_reduced_risk,
                  moved_from_very_significant_and_significant_to_moderate_or_low: third_flood_project_outcome.moved_from_very_significant_and_significant_to_moderate_or_low,
                  households_protected_from_loss_in_20_percent_most_deprived: third_flood_project_outcome.households_protected_from_loss_in_20_percent_most_deprived
                },
                '3': {
                  financial_year: fourth_flood_project_outcome.financial_year,
                  id: fourth_flood_project_outcome.id,
                  households_at_reduced_risk: fourth_flood_project_outcome.households_at_reduced_risk,
                  moved_from_very_significant_and_significant_to_moderate_or_low: fourth_flood_project_outcome.moved_from_very_significant_and_significant_to_moderate_or_low,
                  households_protected_from_loss_in_20_percent_most_deprived: fourth_flood_project_outcome.households_protected_from_loss_in_20_percent_most_deprived
                },
                '4': {
                  financial_year: fifth_flood_project_outcome.financial_year,
                  id: fifth_flood_project_outcome.id,
                  households_at_reduced_risk: fifth_flood_project_outcome.households_at_reduced_risk,
                  moved_from_very_significant_and_significant_to_moderate_or_low: fifth_flood_project_outcome.moved_from_very_significant_and_significant_to_moderate_or_low,
                  households_protected_from_loss_in_20_percent_most_deprived: fifth_flood_project_outcome.households_protected_from_loss_in_20_percent_most_deprived
                }
              }
            },
            js_enabled: "1",
            commit: "Save and continue",
            id: @project.to_param,
            step: "flood_protection_outcomes"
          }
        end

        it 'redirects to the risks' do
          allow_any_instance_of(PafsCore::Project).to receive(:project_end_financial_year).and_return(2020)

          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'risks')
        end
      end

      context 'saving a standard of protection' do
        let(:params) do
          {
            standard_of_protection_after_step: {
              id: "4",
              flood_protection_after: "3"
            },
            commit: "Save and continue",
            id: @project.to_param,
            step: "standard_of_protection_after"
          }
        end

        it 'redirects to the standard of protection' do
          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'standard-of-protection')
        end
      end

      context 'saving an approach' do
        let(:params) do
          {
            approach_step: {
              approach: "Some text",
            },
            commit: "Save and continue",
            id: @project.to_param,
            step: "approach"
          }
        end

        it 'redirects to the approach' do
          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'approach')
        end
      end

      context 'saving the environmental outcomes' do
        let(:params) do
          {
            remove_eel_barrier_step: {
              id: "4",
              remove_eel_barrier: "false"
            },
            commit: "Save and continue",
            id: @project.to_param,
            step: "remove_eel_barrier"
          }
        end

        it 'redirects to the environmental outcomes' do
          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'environmental-outcomes')
        end
      end

      context 'saving a project urgency' do
        let(:params) do
          {
            urgency_step: {
              id: 4,
              urgency_reason: "not_urgent"
            },
            commit: "Save and continue",
            id: @project.to_param,
            step: "urgency"
          }
        end

        it 'redirects to the project urgency' do
          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'urgency')
        end
      end

      context 'saving a project calculator' do
        let(:params) do
          {
            commit: "Save and continue",
            id: @project.to_param,
            step: "funding_calculator_summary"
          }
        end

        it 'redirects to the funding calculator' do
          patch :save, params
          expect(response).to redirect_to project_path(id: @project.to_param, anchor: 'funding-calculator')
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
  end
end
