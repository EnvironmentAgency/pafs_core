# frozen_string_literal: true

module PafsCore::Spreadsheet::Contributors::Coerce
  class FinancialYear < Base
    def perform
      return -1 if value == "Previous years"
      raise("unknown year") if matches.nil?

      matches[0]
    end

    def matches
      @matches = value.match(/(\d+) - (\d+)/)
    end
  end
end
