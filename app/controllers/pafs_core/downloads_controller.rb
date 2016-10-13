# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
class PafsCore::DownloadsController < PafsCore::ApplicationController

  def index
    @project = PafsCore::ProjectSummaryPresenter.new navigator.find(params[:id])

    respond_to do |format|
      format.html

      format.csv do
        @csv = PafsCore::SpreadsheetBuilderService.new.generate_csv([@project])
        send_data @csv, type: "text/csv", filename: "#{@project.reference_number.parameterize}.csv"
      end

      format.xlsx do
        xlsx = PafsCore::SpreadsheetBuilderService.new.generate_xlsx([@project])
        file_path = [Rails.root, "tmp", "#{@project.reference_number.parameterize}.xlsx"].join("/")

        f = File.open(file_path, "wb")
        xlsx.serialize(f)

        send_file file_path, type: "application/xlsx"
        f.close && File.delete(file_path)
      end
    end
  end

  private
  def navigator
    @navigator ||= PafsCore::ProjectNavigator.new current_resource
  end
end
