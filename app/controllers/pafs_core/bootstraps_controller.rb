# frozen_string_literal: true

class PafsCore::BootstrapsController < PafsCore::ApplicationController
  # NOTE: this should be added via a decorator in consuming qpp if needed
  # before_action :authenticate_user!

  def new
    # create a temporary bootstrap project and start the steps
    # for the project name
    # for the project type
    # for the financial year the project stops spending funds
    @project = navigator.create_bootstrap
    redirect_to bootstrap_step_path(id: @project.to_param, step: @project.step)
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
      @project.before_view(params)
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

  def navigator
    @navigator ||= PafsCore::BootstrapNavigator.new current_resource
  end
end
