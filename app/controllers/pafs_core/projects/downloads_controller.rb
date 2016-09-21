# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
class PafsCore::Projects::DownloadsController < PafsCore::ProjectsController
  def index
    @projects = navigator.search(params)

    respond_to do |format|
      format.html

      format.csv do
        @csv = PafsCore::SpreadsheetBuilderService.new.generate_csv(@projects)
        send_data @csv, type: "text/csv", filename: "projects#{Time.zone.now}.csv"
      end

      format.xlsx do
        xlsx = PafsCore::SpreadsheetBuilderService.new.generate_xlsx(@projects)
        file_path = [Rails.root, "tmp", "projects#{Time.zone.now}.xlsx"].join("/")

        f = File.open(file_path, "wb")
        xlsx.serialize(f)

        send_file file_path, type: "application/xlsx"
        f.close && File.delete(file_path)
      end
    end
  end
end
