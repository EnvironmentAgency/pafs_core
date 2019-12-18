module PafsCore
  module FundingCalculatorVersion
    extend ActiveSupport::Concern

    class Check
      VERSION_MAP = {
        v8: {column: 'B', row: '3', version_text: /^Version 8/},
        v9: {column: 'B', row: '4', version_text: /^Version 9/}
      }.freeze

      attr_reader :sheet

      def initialize(sheet)
        @sheet = sheet
      end

      def calculator_version
        VERSION_MAP.each do |k, v|
          return k if sheet.cell(v[:column], v[:row]).to_s.match?(version_check)
        end
      end
    end

    included do
      def calculator_version
        @calculator_version ||= Check.new(sheet).calculator_version
      end
    end
  end
end
