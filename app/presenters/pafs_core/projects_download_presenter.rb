# frozen_string_literal: true
module PafsCore
  class ProjectsDownloadPresenter
    attr_reader :projects
    def initialize(projects)
      @projects = projects
    end

    def count
      projects.count
    end

    def shapefile_count
      projects.count
    end

    def urgency_count
      projects.count
    end
  end
end