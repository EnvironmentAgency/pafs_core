# frozen_string_literal: true
require "rubyXL"

module PafsCore
  class SpreadsheetService
    include PafsCore::Fcerm1
    FIRST_DATA_ROW = 7

    def generate_xlsx(project)
      workbook = read_fcerm1_template
      # until sheet names are fixed, take the first sheet in the workbook
      sheet = workbook.worksheets[0]
      add_project_to_sheet(sheet, PafsCore::SpreadsheetPresenter.new(project),
                           FIRST_DATA_ROW)
      workbook
    end

    def generate_csv(project)
      CSV.generate do |csv|
        csv << %w[ not yet implemented ]
      end
    end

  private
    def read_fcerm1_template
      RubyXL::Parser.parse(PafsCore::Engine.root.join("lib", "fcerm1_template.xlsx"))
    end

    def add_project_to_sheet(sheet, project, row_no)
      FCERM1_COLUMN_MAP.each do |col|
        if col.fetch(:export, true)
          range = col.fetch(:date_range, false)
          name = col[:field_name]
          if range
            start_column = column_index(col[:column])
            years = [-1].concat((2015..2027).to_a)
            years.each_with_index do |year, i|
              sheet[row_no][start_column + i].change_contents(project.send(name, year))
              # sheet.add_cell(row_no, start_column + i, project.send(name, year))
            end
          else
            sheet[row_no][column_index(col[:column])].
              change_contents(project.send(col[:field_name]))
            # sheet.add_cell(row_no, column_index(col[:column]),
            #                project.send(col[:field_name]))
          end
        end
      end
    end
  end
end
