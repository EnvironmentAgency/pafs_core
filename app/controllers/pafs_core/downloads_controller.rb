# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
class PafsCore::DownloadsController < PafsCore::ApplicationController

  def index
    @project = PafsCore::ProjectSummaryPresenter.new navigator.find(params[:id])
  end

  def proposal
    @project = PafsCore::ProjectSummaryPresenter.new navigator.find(params[:id])

    respond_to do |format|
      format.csv do
        @csv = PafsCore::SpreadsheetBuilderService.new.generate_csv([@project])
        send_data @csv, type: "text/csv", filename: "#{ref_to_file_name(@project)}_FCERM1.csv"
      end

      format.xlsx do
        xlsx = PafsCore::SpreadsheetBuilderService.new.generate_xlsx([@project])
        file_path = Rails.root.join("tmp", "#{ref_to_file_name(@project)}_FCERM1.xlsx")

        f = File.open(file_path, "wb")
        xlsx.serialize(f)

        send_file file_path, type: Mime::XLSX
        f.close && File.delete(file_path)
      end
    end
  end

  def benefit_area
    @project = navigator.find_project_step(params[:id], :map)
    @project.download do |data, filename, content_type|
      send_data(data,
                filename: benefit_area_filename(@project, filename),
                type: content_type)
    end
  end

  # GET
  def delete_benefit_area
    @project = navigator.find_project_step(params[:id], :map)
    @project.delete_benefit_area_file
    redirect_to project_step_path(id: @project.to_param, step: :map)
  end

  def funding_calculator
    @project = navigator.find_project_step(params[:id], :funding_calculator)
    @project.download do |data, filename, content_type|
      send_data(data,
                filename: benefit_area_filename(@project, filename),
                type: content_type)
    end
  end

  # GET
  def delete_funding_calculator
    @project = navigator.find_project_step(params[:id], :funding_calculator)
    @project.delete_calculator
    redirect_to project_step_path(id: @project.to_param, step: :funding_calculator)
  end

  def moderation
    @project = PafsCore::ModerationPresenter.new(navigator.find(params[:id]))
    @project.download do |data, filename, content_type|
      send_data(data, filename: filename, type: content_type)
    end
  end

  private
  def navigator
    @navigator ||= PafsCore::ProjectNavigator.new current_resource
  end

  def benefit_area_filename(project, original_filename)
    "#{ref_to_file_name(project)}_benefit_area#{File.extname(original_filename)}"
  end

  def pfcalc_filename(project, original_filename)
    "#{ref_to_file_name(project)}_PFcalculator#{File.extname(original_filename)}"
  end

  def ref_to_file_name(project)
    @project.reference_number.parameterize.upcase
  end
end
