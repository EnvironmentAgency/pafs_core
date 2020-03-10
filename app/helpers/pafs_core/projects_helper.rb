# frozen_string_literal: true
module PafsCore
  module ProjectsHelper
    def financial_year_end_for(date)
      Date.new(date.month < 4 ? date.year : date.year + 1, 3, 31)
    end

    def rma_user?
      current_resource.respond_to?(:primary_area) && current_resource.primary_area.rma?
    end

    def pso_user?
      current_resource.respond_to?(:primary_area) && current_resource.primary_area.pso_area?
    end

    def ea_user?
      current_resource.respond_to?(:primary_area) && current_resource.primary_area.ea_area?
    end

    def status_label_for(state)
      scope = "pafs_core.projects.status"
      scope = scope + ".rma" if current_resource.present? && rma_user?
      I18n.t("#{state}_label", scope: scope)
    end

    def force_pso_to_use_pol?
      ENV.fetch('FORCE_PSO_TO_POL', false)
    end

    def pso_can_create_project?
      !ENV.fetch('PSO_CANNOT_CREATE_PROJECTS', false)
    end

    def can_revert_to_draft?(project)
      !force_pso_to_use_pol?
    end

    def can_change_project_state?(project)
      (rma_user? || pso_user?) && (!project.pso? || (project.pso? && !force_pso_to_use_pol?))
    end

    def can_create_project?
      rma_user? || (pso_user? && pso_can_create_project?)
    end

    def can_edit_project_sections?(project)
      !project.submitted? && !project.archived? && !(force_pso_to_use_pol? && project.pso?)
    end

    def project_status_change_link(project)
      return unless project.archived? || project.draft?
      return content_tag(:span, 'EA Projects are now managed in PoL') if project.pso? && force_pso_to_use_pol?
      return unless rma_user? || pso_user?

      return link_to("Revert to draft", unlock_project_path(id: project.to_param)) if project.archived?
      return link_to("Archive", pafs_core.archive_project_path(project)) if project.draft?
    end

    def project_status_line(project)
      out = [
        status_label_for(project.status),
      ]

      project_change_link = project_status_change_link(project)

      out << [
        ' | ',
        project_change_link
      ] if project_change_link

      out.compact.join.html_safe
    end

    def funding_value_label(fv)
      t("#{fv}_label", scope: "pafs_core.projects.steps.funding_values")
    end

    def class_for_summary_list(underline_all)
      "summary-list underlined-#{underline_all ? 'all-' : ''}items"
    end

    def flood_class_for_sop(p)
      if p.protects_against_coastal_erosion?
        " with-seperator"
      else
        ""
      end
    end

    def str_year(year)
      if year < 0
        "previous"
      else
        year.to_s
      end
    end

    def formatted_financial_year(year)
      if year < 0
        t("previous_years_label")
      else
        "#{year} to #{year + 1}"
      end
    end

    def urgency_flag(project)
      if project.urgency_reason.present? && project.urgency_reason != "not_urgent"
        %{<span class="urgent">Yes</span>}.html_safe
      else
        ""
      end
    end

    def formatted_financial_month_and_year(year)
      if year < 0
        t("previous_years_label")
      else
        "April #{year} to March #{year + 1}"
      end
    end

    def funding_table_cell(year, funding_source)
      "#{str_year(year)}-#{funding_source} numeric"
    end

    def fy_total_class(year)
      "#{str_year(year)}-total"
    end

    def six_year_limit_date
      "31 March 2021"
    end

    def housing_protection_table_cell(year, thing)
      "#{str_year(year)}-#{funding_source} numeric"
    end

    def strategic_officer_link
      link_to t("strategic_officer_label"), t("strategic_officer_link"),
        rel: "external", target: "_blank"
    end

    def urgency_reason_text(reason)
      I18n.t("#{reason}_label", scope: "pafs_core.urgency_reasons")
    end

    def format_date(dt)
      return "" if dt.nil?
      dt.strftime("%-d %B %Y")
    end

    def project_type_label(pt)
      I18n.t("#{pt.downcase}_label", scope: "pafs_core.projects.steps.project_type") unless pt.nil?
    end

    def location_search_results_for(results, query, word, description)
      [
        pluralize(results.size, word),
        description,
        content_tag(:strong, query, class: "bold-small")
      ].join(" ").html_safe
    end

    def confidence_band_label(confidence_type, option)
      [
        content_tag(
          :span,
          I18n.t(
            :label,
            scope: ["pafs_core", "confidence", confidence_type, option]
          ),
          class: "bold-small"
        ),
        content_tag(
          :div,
          I18n.t(
            "description",
            scope: ["pafs_core", "confidence", confidence_type, option]
          )
        )
      ].join("").html_safe
    end

    def compound_standard_of_protection_label(option)
      [
        content_tag(
          :span,
          I18n.t(
            option,
            scope: "pafs_core.standard_of_protection"
          ),
          class: "bold-small"
        ),
        content_tag(
          :div,
          I18n.t(
            "#{option}_description",
            scope: "pafs_core.standard_of_protection"
          )
        )
      ].join("").html_safe
    end

    def search_result_label(search_string, result)
      if search_string != nil
        search_string
      else
        [result[:eastings], result[:northings]].join(",")
      end
    end

    def file_extension(file_name)
      file_name.split(".").last.upcase
    end

    # def key_date_field(f, attr)
    #   # expecting attr to end with either '_month' or '_year'
    #   date_type = attr.to_s.split("_").last
    #   range = date_type == "month" ? 1..12 : 2000..2099
    #   length = date_type == "month" ? 2 : 4
    #
    #   content_tag(:div, class: "form-group form-group-#{date_type}") do
    #     concat(f.label(attr, t(".#{date_type}_label"), class: "form-label"))
    #     concat(f.number_field(attr, in: range, maxlength: length, class: "form-control form-#{date_type}"))
    #   end
    # end
  end
end
