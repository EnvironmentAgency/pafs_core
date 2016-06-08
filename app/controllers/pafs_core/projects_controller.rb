# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
class PafsCore::ProjectsController < PafsCore::ApplicationController
  # NOTE: this should be added via a decorator in consuming qpp if needed
  # before_action :authenticate_user!

  def index
    # dashboard page
    # (filterable) list of projects
    @projects = project_navigator.search(params)
  end

  def show
    # project summary page
    @project = PafsCore::ProjectSummaryPresenter.new project_navigator.find(params[:id])
  end

  def new
    # start a new project
    # ask the 'start within 6 years' question
    # @project = project_navigator.start_new_project
    # redirect_to project_step_path(id: @project.to_param, step: @project.step)
  end

  def create
    # if the project starts within the next 6 years
    # save the new project and start the steps
    within_six_years = params.fetch(:yes_or_no, nil)
    if within_six_years.nil?
      #TODO: set an error message requesting the user to select an option
      flash[:alert] = "Please choose Yes or No"
      render :new
    elsif within_six_years == "yes"
      @project = project_navigator.start_new_project
      redirect_to reference_number_project_path(@project)
    else
      # not a project we want to know about (yet)
      redirect_to pipeline_projects_path
    end
  end

  # GET
  def pipeline
  end

  # GET
  def reference_number
    @project = project_navigator.find_project_step(params[:id], PafsCore::ProjectNavigator.first_step)
  end

  # GET
  def step
    # edit step
    @project = project_navigator.find_project_step(params[:id], params[:step])

    # This is necessary for the map to be set on the location step
    if params[:step] == "location"
      @results = PafsCore::MapService.new
                                     .find(
                                       params[:q],
                                       @project.project_location
                                     )
    elsif params[:step] == "map"
      @map_centre = PafsCore::MapService.new
                                        .find(
                                          @project.benefit_area_centre.join(","),
                                          @project.project_location
                                        )
    end
    # we want to go to the page in the process requested in the
    # params[:step] part of the URL and display the appropriate form
    render @project.view_path
  end

  # PATCH
  def save
    # submit data for the current step and continue or exit
    # if request is exit redirect to summary or dashboard?
    # else go to next step
    @project = project_navigator.find_project_step(params[:id], params[:step])
    # each step is responsible for managing their params safely
    if @project.update(params)
      # if the next step is :main_risk, handle the case where only 1 risk
      # has been selected by auto-updating the main risk with the selected one
      # and then moving to the subsequent step, bypassing the main risk step
      # from the user's perspective.
      if @project.step == :main_risk
        p = project_navigator.find_project_step(params[:id], :main_risk)
        if p.risks.count == 1
          p.update({main_risk_step: { main_risk: p.risks.first.to_s }})
          @project = p
        end
      end

      redirect_to project_step_path(id: @project.to_param, step: @project.step)
    else
      render @project.view_path
    end
  end

  # GET
  def download_funding_calculator
    @project = project_navigator.find_project_step(params[:id], :funding_calculator)
    @project.download do |data, filename, content_type|
      send_data(data, filename: filename, type: content_type)
    end
  end

private
  def project_navigator
    @project_navigator ||= PafsCore::ProjectNavigator.new current_resource
  end
end
