# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
class PafsCore::ProjectsController < PafsCore::ApplicationController
  # NOTE: this should be added via a decorator in consuming qpp if needed
  # before_action :authenticate_user!

  helper_method :project_sort_order, :project_sort_column

  def index
    # dashboard page
    # (filterable) list of projects
    @projects = navigator.search(params)

    if params[:all]
      projects_per_page = @projects.any? ? @projects.size : 1
    else
      page = params.fetch(:page, 1)
      projects_per_page = params.fetch(:per, 10)
    end

    @projects = @projects.page(page).per(projects_per_page)
  end

  def show
    # project summary page
    @project = PafsCore::ProjectSummaryPresenter.new navigator.find(params[:id])
  end

  # GET
  def archive
    @project = navigator.find(params[:id])
    if @project.submission_state.archived!
      redirect_to pafs_core.confirm_project_path(@project)
    else
      render :show
    end
  end

  # GET
  def pipeline
  end

  # GET
  def complete
    # RMA completes a proposal for PSO review
    @project = PafsCore::ValidationPresenter.new navigator.find(params[:id])
    if @project.complete?
      @project.submission_state.complete!
      redirect_to pafs_core.confirm_project_path(@project)
    else
      render :show
    end
  end

  def submit
    # PSO mark proposal as submitted to APT
    @project = navigator.find(params[:id])
    @project.submission_state.submit!

    # send files to asite
    # asite.submit_project(@project)
    PafsCore::AsiteSubmissionJob.perform_later(@project.id)
    PafsCore::Pol::SubmissionJob.perform_later(@project.id)

    redirect_to pafs_core.confirm_project_path(@project)
  end

  def unlock
    # PSO revert to draft
    @project = navigator.find(params[:id])
    @project.submission_state.unlock!
    redirect_to pafs_core.project_path(@project)
  end

  def confirm
    @project = navigator.find(params[:id])
    if @project.archived?
      render "confirm_archive"
    elsif @project.completed?
      if current_resource.primary_area.rma?
        render "confirm_rma"
      else
        render "confirm_pso"
      end
    elsif @project.submitted?
      render "confirm_area"
    else
      redirect_to pafs_core.project_path(@project)
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
    elsif !@project.project.draft?
      redirect_to project_path(@project)
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

    if @project.disabled?
      raise_not_found
    elsif !@project.project.draft?
      redirect_to project_path(@project)
    elsif @project.update(params)
      # each step is responsible for managing their params safely
      next_step = navigator.next_step(@project.step, @project)
      if next_step == :summary
        step = navigator.next_step_raw(@project.step, @project)
        anchor = navigator.step_anchor(step)
        anchor = anchor.nil? ? '' : anchor.values.first

        # we're at the end so return to project summary
        if anchor.empty?
          redirect_to project_path(id: @project.to_param)
        else
          redirect_to project_path(id: @project.to_param, anchor: anchor.to_s.dasherize)
        end
      else
        redirect_to project_step_path(id: @project.to_param, step: next_step)
      end
    else
      # NOTE: not calling @project.before_view, but we could if we need to
      render @project.view_path
    end
  end

private
  def project_params
    params.require(:project).permit(:fcerm_gia, :local_levy)
  end

  def navigator
    @navigator ||= PafsCore::ProjectNavigator.new current_resource
  end

  def project_sort_column
    params[:sort_col].to_s
  end

  def project_sort_order
    params[:sort_order].to_s
  end
  # def asite
  #   @asite ||= PafsCore::AsiteService.new current_resource
  # end
end
