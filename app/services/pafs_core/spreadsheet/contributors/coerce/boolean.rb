# frozen_string_literal: true

module PafsCore::Spreadsheet::Contributors::Coerce
  class Boolean < Base
    def perform
      value == 'yes'
    end
  end
end


