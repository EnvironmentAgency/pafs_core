# frozen_string_literal: true

module PafsCore::Spreadsheet::Contributors
  class Export
    attr_reader :project, :workbook

    SHEET_NAME = 'Funding Contributors'
    SHEET_TITLES = %w[Project Name Type Year Amount Secured Constrained]
    SHORT_NAME_SCOPE = 'funding_sources.short'

    def initialize(workbook, project)
      @project = project
      @workbook = workbook
    end

    def generate
      write_title_row

      project.funding_contributors.find_each.with_index do |contributor, index|
        row_index = next_row_index

        sheet.add_cell(row_index, 0, project.reference_number)
        sheet.add_cell(row_index, 1, contributor.name)
        sheet.add_cell(row_index, 2, I18n.t(contributor.contributor_type, scope: SHORT_NAME_SCOPE))
        sheet.add_cell(row_index, 3, financial_year(contributor.funding_value.financial_year))
        sheet.add_cell(row_index, 4, contributor.amount)
        sheet.add_cell(row_index, 5, contributor.secured ? 'yes' : 'no')
        sheet.add_cell(row_index, 6, contributor.constrained ? 'yes' : 'no')
      end
    end

    private

    def financial_year(value)
      return 'Previous years' if value == -1

      "#{value} - #{value + 1}"
    end

    def sheet
      @sheet ||= workbook[SHEET_NAME] || workbook.add_worksheet(SHEET_NAME)
    end

    def write_title_row
      return unless sheet[0].nil?

      SHEET_TITLES.each_with_index do |title_cell, index|
        sheet.add_cell(0, index, title_cell)
      end
    end

    def next_row_index
      sheet.sheet_data.rows.size
    end
  end
end
