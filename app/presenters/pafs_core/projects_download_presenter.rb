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
      @urgency_count ||= calc_urgency_count
    end

  private
    def calc_urgency_count
      projects.where.not(urgency_reason: "not_urgent").count
    end
  end
end
