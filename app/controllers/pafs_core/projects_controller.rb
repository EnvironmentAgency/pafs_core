# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
class PafsCore::ProjectsController < PafsCore::ApplicationController
  # NOTE: this should be added via a decorator in consuming qpp if needed
  # before_action :authenticate_user!

  def index
    # dashboard page
    # (filterable) list of projects
    @projects = navigator.search(params)
    @csv = PafsCore::SpreadsheetBuilderService.new.generate_csv(@projects)
    @xlsx = PafsCore::SpreadsheetBuilderService.new.generate_xlsx(@projects)
    respond_to do |format|
      format.html

      format.csv do
        send_data @csv, type: "text/csv", filename: "projects#{Time.zone.now}.csv"
      end

      format.xlsx do
        send_data @xlsx.to_stream.read, type: "application/xlsx", filename: "projects#{Time.zone.now}.xlsx"
      end
    end
  end

  def show
    # project summary page
    @project = PafsCore::ProjectSummaryPresenter.new navigator.find(params[:id])
  end

  # GET
  def pipeline
  end

  # GET
  # def reference_number
  #   @project = navigator.find_project_step(params[:id], navigator.first_step)
  # end

  # GET
  def submit
    @project = PafsCore::ProjectService.new(current_resource).find_project(params[:id])
  end

  # GET
  def step
    # edit step
    @project = navigator.find_project_step(params[:id], params[:step])

    # TODO: move this into before_view for the appropriate steps
    # This is necessary for the map to be set on the location step
    # if params[:step] == "location"
    #   @results = PafsCore::MapService.new
    #                                  .find(
    #                                    params[:q],
    #                                    @project.project_location
    #                                  )
    # elsif params[:step] == "map"
    #   @map_centre = PafsCore::MapService.new
    #                                     .find(
    #                                       @project.benefit_area_centre.join(","),
    #                                       @project.project_location
    #                                     )
    # end
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
      if next_step == :summary
        # we're at the end so return to project summary
        redirect_to project_path(id: @project.to_param)
      else
        redirect_to project_step_path(id: @project.to_param, step: next_step)
      end
    else
      # NOTE: not calling @project.before_view, but we could if we need to
      render @project.view_path
    end
  end

  # GET
  def download_funding_calculator
    @project = navigator.find_project_step(params[:id], :funding_calculator)
    @project.download do |data, filename, content_type|
      send_data(data, filename: filename, type: content_type)
    end
  end

  # GET
  def delete_funding_calculator
    @project = navigator.find_project_step(params[:id], :funding_calculator)
    @project.delete_calculator
    redirect_to project_step_path(id: @project.to_param, step: :funding_calculator)
  end

  # GET
  def download_benefit_area_file
    @project = navigator.find_project_step(params[:id], :map)
    @project.download do |data, filename, content_type|
      send_data(data, filename: filename, type: content_type)
    end
  end

  # GET
  def delete_benefit_area_file
    @project = navigator.find_project_step(params[:id], :map)
    @project.delete_benefit_area_file
    redirect_to project_step_path(id: @project.to_param, step: :map)
  end

private
  def project_params
    params.require(:project).permit(:fcerm_gia, :local_levy)
  end

  def navigator
    @navigator ||= PafsCore::ProjectNavigator.new current_resource
  end
end
