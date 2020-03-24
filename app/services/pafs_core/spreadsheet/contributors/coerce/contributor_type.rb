# frozen_string_literal: true

module PafsCore::Spreadsheet::Contributors::Coerce
  class ContributorType < Base
    TYPE_LOOKUP = I18n.t("funding_sources.short").invert.freeze

    def perform
      TYPE_LOOKUP[value] || raise("Unknown contributor type")
    end
  end
end
