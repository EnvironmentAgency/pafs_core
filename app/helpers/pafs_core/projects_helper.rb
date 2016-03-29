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

    def nav_step_item(project, step)
      project_step = project.navigator.find_project_step(project.to_param, step)
      content_tag(:li) do
        concat(content_tag(:span, class: "complete-flag") do
          icon("check") if project_step.completed?
        end)
        if project_step.disabled?
          concat(content_tag(:span, class: "inactive") do
            step_label(step)
          end)
        elsif project_step.step_name.to_sym == step.to_sym
          concat(content_tag(:span, class: "selected") do
            step_label(step)
          end)
        else
          concat link_to step_label, project_step_path(project_step)
        end
      end
    end

    def step_label(step)
      t("#{step}_step_label")
    end
  end
end
