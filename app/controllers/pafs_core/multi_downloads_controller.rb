# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

class PafsCore::MultiDownloadsController < PafsCore::ApplicationController
  include PafsCore::Files

  def index
    @projects = navigator.find_apt_projects

    @submitted = @projects.collect { |p| (p.state.state == 'submitted') ? p : nil }.compact!
    @drafts = @projects.collect { |p| (p.state.state == 'draft') ? p : nil }.compact!
    @review = @projects.collect { |p| (p.state.state == 'review') ? p : nil }.compact!
    @archived = @projects.collect { |p| (p.state.state == 'archived') ? p : nil }.compact!

    @downloads = PafsCore::ProjectsDownloadPresenter.new(download_service.download_info, @projects.count)
  end

  def generate
    # initiate generation of documents for the user's area
    # ensuring that there isn't a process already underway for the area
    download_service.generate_downloads
    redirect_to pafs_core.multi_downloads_path
  end

  def proposals
    info = download_service.download_info
    if info.documentation_state.ready?
      download_service.fetch_fcerm1 do |data, filename|
        send_data data, filename: filename
      end
    else
      redirect_to pafs_core.multi_downloads_path
    end
  end

  def funding_calculators
    info = download_service.download_info
    if info.documentation_state.ready?
      download_service.fetch_funding_calculators do |data, data_type, filename|
        send_data data, type: data_type, filename: filename
      end
    else
      redirect_to pafs_core.multi_downloads_path
    end
  end

  def benefit_areas
    info = download_service.download_info
    if info.documentation_state.ready?
      download_service.fetch_benefit_areas do |data, data_type, filename|
        send_data data, type: data_type, filename: filename
      end
    else
      redirect_to pafs_core.multi_downloads_path
    end
  end

  def moderations
    info = download_service.download_info
    if info.documentation_state.ready?
      download_service.fetch_moderations do |data, data_type, filename|
        send_data data, type: data_type, filename: filename
      end
    else
      redirect_to pafs_core.multi_downloads_path
    end
  end

  private
  def navigator
    @navigator ||= PafsCore::ProjectNavigator.new current_resource
  end

  def download_service
    @download_service ||= PafsCore::AreaDownloadService.new current_resource
  end
end
