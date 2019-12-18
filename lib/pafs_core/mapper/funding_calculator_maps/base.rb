# frozen_string_literal: true

module PafsCore
  module Mapper
    module FundingCalculatorMaps
      class Base
        attr_reader :sheet

        def initialize(sheet)
          @sheet = sheet
        end

        def extract_data
          fail "Override #extract_data"
        end
      end
    end
  end
end
