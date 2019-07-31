# frozen_string_literal: true

module PafsCore::Spreadsheet::Contributors
  class ImportAll
    attr_reader :project, :workbook

    SHEET_NAME = 'Funding Contributors'
    SHORT_NAME_SCOPE = 'funding_sources.short'

    def initialize(workbook)
      @workbook = workbook
    end

    def sheet
      @sheet ||= workbook.sheet(SHEET_NAME) || fail('Could not find contributor sheet')
    end

    def import
      PafsCore::FundingContributor.transaction do
        index = 0

        sheet.each_row_streaming(pad_cells: true) do |row|
          index += 1

          begin
            Contributor.import(row.map(&:formatted_value))
            Rails.logger.debug row.inspect
          rescue StandardError => e
            Rails.logger.warn "Failed to import row #{index} #{e.message}"
          end
        end
      end
    end
  end
end
