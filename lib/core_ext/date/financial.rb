# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module CoreExtensions
  module Date
    module Financial
      def uk_financial_year
        case
        when self.month < 4 then self.year - 1
        else self.year
        end
      end
    end
  end
end
