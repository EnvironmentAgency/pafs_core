# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

require "roo"

module PafsCore
  class CalculatorParser
    include PafsCore::FundingCalculatorVersion

    attr_reader :sheet, :project

    PARSER_MAPS = {
      v8: PafsCore::CalculatorMaps::V8,
      v9: PafsCore::CalculatorMaps::V9
    }

    SHEET_NAMES = [
      'PF Calculator',
      'PF calculator'
    ].freeze

    def initialize(calculator, project)
      calculator_sheet_name = calculator.sheets.grep(/PF Calculator/i).first || raise("No calculator sheet found")
      @sheet = calculator.sheet(calculator_sheet_name)
      @project = project
    end

    def self.parse(file, project)
      if File.extname(file.path) == ".xlsx"
        calculator = Roo::Excelx.new(file.path)
        begin
          new(calculator, project).extract_data
        rescue StandardError => e
          puts e
        end
      else
        raise "require an xlsx file"
      end
    end

    def parser_map
      PARSER_MAPS[calculator_version] || fail('Unknown PFC version')
    end

    def data
      @data ||= parser_map.new(sheet).data
    end

    def extract_data
      project.update(data)
    end

    def binary_value(value)
      value.casecmp("yes") == 0
    end
  end
end
