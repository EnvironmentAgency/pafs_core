# frozen_string_literal: true

module PafsCore::Spreadsheet::Contributors::Coerce
  class FinancialYear < Base
    def perform
      return -1 if value == 'Previous years'
      fail('unknown year') if matches.nil?

      matches[1]
    end

    def matches
      @matches = value.match(/(\d+) - (\d+)/)
    end
  end
end

