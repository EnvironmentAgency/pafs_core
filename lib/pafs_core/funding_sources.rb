# frozen_string_literal: true
module PafsCore
  module FundingSources
    FUNDING_SOURCES = [:fcerm_gia,
                       :local_levy,
                       :internal_drainage_boards,
                       :public_contributions,
                       :private_contributions,
                       :other_ea_contributions,
                       :growth_funding,
                       :not_yet_identified].freeze

    def current_funding_values
      funding_values.select { |fv| fv.financial_year <= project_end_financial_year }.sort_by(&:financial_year)
      # if this is a db query we lose inputted data when there are errors
      # and we send the user back to fix it
      # It also breaks validating that every column has at least one value overall
      # funding_values.to_financial_year(project_end_financial_year)
    end

    def selected_funding_sources
      FUNDING_SOURCES.select { |s| send "#{s}?" }
    end

    def unselected_funding_sources
      FUNDING_SOURCES - selected_funding_sources
    end

    def total_for(fs)
      current_funding_values.reduce(0) { |sum, fv| sum + (fv.send(fs) || 0) }
    end

    def grand_total
      selected_funding_sources.reduce(0) { |sum, fs| sum + total_for(fs) }
    end

    def funding_source_label(fs)
      I18n.t(fs, scope: "funding_sources")
    end
  end
end
