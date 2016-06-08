# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  module ProjectsHelper
    def financial_year_end_for(date)
      Date.new(date.month < 4 ? date.year : date.year + 1, 3, 31)
    end

    def six_year_limit_date
      Date.new(2021, 3, 31).to_formatted_s(:long_ordinal)
    end

    def strategic_officer_link
      link_to t("strategic_officer_label"), t("strategic_officer_link"),
        rel: "external", target: "_blank"
    end

    def urgency_reason_text(reason)
      I18n.t("#{reason}_label", scope: "pafs_core.urgency_reasons")
    end

    # def project_step_path(project)
    #   pafs_core.project_step_path(id: project.to_param, step: project.step)
    # end
    #

    def nav_step_item(project, step)
      nav_step = PafsCore::ProjectNavigator.build_project_step(project.project, step, current_resource)
      content_tag(:li) do
        concat(content_tag(:span, class: "complete-flag") do
          icon("check") if nav_step.completed?
        end)
        if nav_step.disabled?
          concat(content_tag(:span, class: "inactive") do
            step_label(step)
          end)
        elsif project.is_current_step?(step)
          concat(content_tag(:span, class: "selected") do
            step_label(step)
          end)
        else
          concat link_to(step_label(step),
                         pafs_core.project_step_path(id: nav_step.to_param,
                                                     step: nav_step.step),
                                                     class: "nav-link")
        end
      end
    end

    def step_label(step)
      t("#{step}_step_label")
    end

    def key_date_field(f, attr)
      # expecting attr to end with either '_month' or '_year'
      date_type = attr.to_s.split("_").last
      range = date_type == "month" ? 1..12 : 2000..2099
      length = date_type == "month" ? 2 : 4

      content_tag(:div, class: "form-group form-group-#{date_type}") do
        concat(f.label(attr, t(".#{date_type}_label"), class: "form-label"))
        concat(f.number_field(attr, in: range, maxlength: length, class: "form-control form-#{date_type}"))
      end
    end
  end
end
