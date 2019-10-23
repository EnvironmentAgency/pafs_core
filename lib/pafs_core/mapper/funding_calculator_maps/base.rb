# frozen_string_literal: true

module Mapper
  module FundingCalculatorMaps
    class Base
      CALCULATOR_SHEET_NAME = "PF Calculator"

      attr_reader :sheet

      def initialize(sheet)
        @sheet = sheet
      end

      def self.matches?(sheet)
        sheet.cell(VERSION_COL, VERSION_ROW).to_s.match?(VERSION_REGEX)
      end

      def extract_data
        fail "Override #extract_data"
      end
    end
  end
end

