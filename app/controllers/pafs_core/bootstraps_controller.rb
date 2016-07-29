# frozen_string_literal: true
class PafsCore::BootstrapsController < PafsCore::ApplicationController
  # NOTE: this should be added via a decorator in consuming qpp if needed
  # before_action :authenticate_user!

  def show
    # project summary page
    @project = PafsCore::ProjectSummaryPresenter.new navigator.find(params[:id])
  end

  def new
    # bootstrap a new project by asking:
    # whether GiA funding is required before 31 March 2021
    # whether Local levy funding is required before 31 March 2021
    # for the project name
    # for the project type
    # for the financial year the project stops spending funds
    @project = navigator.new_bootstrap
  end

  # POST
  def funding
    # this is 'new' part 2
    # continue initialising a project by asking whether Local Levy is required before 31 March 2021
    @project = navigator.new_bootstrap(project_params)
    if @project.fcerm_gia.nil?
      @project.errors.add(:fcerm_gia, "^Tell us if you need Grant in Aid funding before 31 March 2021")
      render :new
    end
  end

  # POST
  def create
    # if the project starts within the next 6 years
    # save the new project and start the steps
    @project = navigator.new_bootstrap(project_params)

    if !@project.fcerm_gia.nil? && !@project.local_levy.nil?
      if @project.fcerm_gia? || @project.local_levy?
        # create project
        @project = navigator.create_bootstrap(project_params)
        redirect_to bootstrap_step_path(id: @project.to_param, step: @project.step)
      else
        # not a project we want to know about (yet)
        redirect_to pipeline_projects_path
      end
    elsif @project.fcerm_gia.nil?
      @project = navigator.new_bootstrap(project_params)
      @project.errors.add(:fcerm_gia, "^Tell us if you need Grant in Aid funding before 31 March 2021")
      render :new
    elsif @project.local_levy.nil?
      @project = navigator.new_bootstrap(project_params)
      @project.errors.add(:local_levy, "^Tell us if you need local levy funding before 31 March 2021")
      render :funding
    end
  end

  # GET
  def step
    # edit step
    @project = navigator.find_project_step(params[:id], params[:step])
    # we want to go to the page in the process requested in the
    # params[:step] part of the URL and display the appropriate form
    if @project.disabled?
      raise_not_found
    else
      # give the step the opportunity to do any tasks prior to being viewed
      @project.before_view
      # render the step
      render @project.view_path
    end
  end

  # PATCH
  def save
    # submit data for the current step and continue or exit
    # if request is exit redirect to summary or dashboard?
    # else go to next step
    @project = navigator.find_project_step(params[:id], params[:step])
    # each step is responsible for managing their params safely
    if @project.update(params)
      next_step = navigator.next_step(@project.step, @project)
      if next_step == navigator.last_step
        # we're at the end of the bootstrap
        # create a project and copy the details over
        @project = navigator.bootstrap_to_project(@project.to_param)
        redirect_to project_path(id: @project.to_param)
      else
        redirect_to bootstrap_step_path(id: @project.to_param, step: next_step)
      end
    else
      # NOTE: not calling @project.before_view, but we could if we need to
      render @project.view_path
    end
  end

private
  def project_params
    params.require(:bootstrap).permit(:fcerm_gia, :local_levy)
  end

  def navigator
    @navigator ||= PafsCore::BootstrapNavigator.new current_resource
  end
end
