# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  module ProjectsHelper
    def financial_year_end
      now = Date.today
      Date.new(now.month < 4 ? now.year : now.year + 1, 3, 31)
    end

    def six_year_limit_date
      (financial_year_end + 6.years).to_formatted_s(:long_ordinal)
    end

    def project_step_path(project)
      pafs_core.project_step_path(id: project.to_param, step: project.step)
    end
  end
end
