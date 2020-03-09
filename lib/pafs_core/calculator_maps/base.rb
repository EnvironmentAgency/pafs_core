module PafsCore
  module CalculatorMaps
    class Base
      attr_reader :sheet

      def initialize(sheet)
        @sheet = sheet
      end

      def data
        fail "Override #data in subclass"
      end

      def binary_value(value)
        return false if value.nil?

        value.casecmp("yes") == 0
      end
    end
  end
end

