# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "zip"

class PafsCore::DownloadsController < PafsCore::ApplicationController
  include PafsCore::Files

  def index
    @project = PafsCore::ProjectSummaryPresenter.new navigator.find(params[:id])
  end

  def all
    @downloads = PafsCore::ProjectsDownloadPresenter.new navigator.find_apt_projects
  end

  def proposal
    @project = PafsCore::ProjectSummaryPresenter.new navigator.find(params[:id])

    respond_to do |format|
      format.csv do
        # @csv = PafsCore::SpreadsheetBuilderService.new.generate_csv([@project])
        @csv = generate_fcerm1(@project, :csv)
        send_data @csv, type: "text/csv", filename: fcerm1_filename(@project.reference_number, :csv)
      end

      format.xlsx do
        xlsx = generate_fcerm1(@project, :xlsx)
        send_data xlsx.stream.read,
          filename: fcerm1_filename(@project.reference_number, :xlsx)
      end
    end
  end

  def proposals
    xlsx = generate_multi_fcerm1(navigator.find_apt_projects, :xlsx)
    send_data xlsx.stream.read, filename: "fcerm_proposals.xlsx"
  end

  def benefit_area
    @project = navigator.find(params[:id])
    fetch_benefit_area_file_for(@project) do |data, filename, content_type|
      send_data(data, filename: filename, type: content_type)
    end
  end

  def benefit_areas
    tmpfile = Tempfile.new
    # make tmpfile an empty Zipfile
    Zip::OutputStream.open(tmpfile) { |_| }
    # now we can open the temporary zipfile
    Zip::File.open(tmpfile.path, Zip::File::CREATE) do |zf|
      navigator.find_apt_projects.each do |project|
        fetch_benefit_area_file_for(project) do |data, filename, _content_type|
          zf.get_output_stream(filename) { |f| f.write(data) }
        end
      end
    end
    send_data(File.read(tmpfile.path), type: "application/zip", filename: "benefit_areas.zip")
  ensure
    tmpfile.close
    tmpfile.unlink
  end

  # GET
  def delete_benefit_area
    @project = navigator.find(params[:id])
    delete_benefit_area_file_for(@project)
    redirect_to project_step_path(id: @project.to_param, step: :benefit_area_file)
  end

  def funding_calculator
    @project = navigator.find(params[:id])
    fetch_funding_calculator_for(@project) do |data, filename, content_type|
      send_data(data,
                filename: filename,
                type: content_type)
    end
  end

  # GET
  def delete_funding_calculator
    @project = navigator.find(params[:id])
    delete_funding_calculator_for(@project)
    redirect_to project_step_path(id: @project.to_param, step: :funding_calculator)
  end

  def moderation
    @project = navigator.find(params[:id])
    generate_moderation_for(@project) do |data, filename, content_type|
      send_data(data,
                filename: filename,
                type: content_type)
    end
  end

  def moderations
    tmpfile = Tempfile.new
    # make tmpfile an empty Zipfile
    Zip::OutputStream.open(tmpfile) { |_| }
    # now we can open the temporary zipfile
    Zip::File.open(tmpfile.path, Zip::File::CREATE) do |zf|
      navigator.find_apt_projects.each do |project|
        generate_moderation_for(project) do |data, filename, _content_type|
          zf.get_output_stream(filename) { |f| f.write(data) }
        end
      end
    end
    send_data(File.read(tmpfile.path), type: "application/zip", filename: "moderations.zip")
  ensure
    tmpfile.close
    tmpfile.unlink
  end

  private
  def navigator
    @navigator ||= PafsCore::ProjectNavigator.new current_resource
  end
end
