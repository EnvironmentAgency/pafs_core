# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "zip"

class PafsCore::MultiDownloadsController < PafsCore::ApplicationController
  include PafsCore::Files

  def index
    @downloads = PafsCore::ProjectsDownloadPresenter.new navigator.find_apt_projects
  end

  def proposals
    xlsx = generate_multi_fcerm1(navigator.find_apt_projects, :xlsx)
    send_data xlsx.stream.read, filename: "fcerm_proposals.xlsx"
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
