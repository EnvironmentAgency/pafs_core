# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
class PafsCore::ProjectsController < PafsCore::ApplicationController
  before_action :authenticate_user!

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
      render "reference_number"
    else
      # not a project we want to know about yet?
      redirect_to projects_path, notice: "Not a 6 year project - so what do we do now?"
    end
  end

  # GET
  def step
    # edit step
    @project = project_navigator.find_project_step(params[:id], params[:step])
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
      redirect_to project_step_path(id: @project.to_param, step: @project.step)
    else
      render @project.view_path
    end
  end

private
  def project_navigator
    @project_navigator ||= PafsCore::ProjectNavigator.new current_user
  end
end
