# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "roo"

module PafsCore
  class CalculatorParserService

    def parse(file, project)
      if File.extname(file.path) == ".xlsx"
        calculator = Roo::Excelx.new(file.path)
        begin
          extract_data(calculator, project)
        rescue => e
          puts e
        end
      else
        raise "require an xlsx file"
      end
    end

    def extract_data(calculator, project)
      sheet = calculator.sheet("PF Calculator")
      data = {}
      data[:strategic_approach] = binary_value(sheet.cell("J", 25))
      data[:raw_partnership_funding_score] = sheet.cell("H", 15)
      data[:adjusted_partnership_funding_score] = sheet.cell("H", 19)
      data[:pv_whole_life_costs] = sheet.cell("H", 37)
      data[:pv_whole_life_benefits] = sheet.cell("H", 29)
      data[:duration_of_benefits] = sheet.cell("H", 27)
      data[:hectares_of_net_water_dependent_habitat_created] = sheet.cell("C", 80)
      data[:hectares_of_net_water_intertidal_habitat_created] = sheet.cell("C", 81)
      data[:kilometres_of_protected_river_improved] = sheet.cell("C", 82)

      #data
      project.update(data)
    end

    def binary_value(value)
      value.casecmp("yes") == 0
    end
  end
end
