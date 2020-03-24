# frozen_string_literal: true

module PafsCore
  module FundingSources

    FUNDING_SOURCES = [
      GRANT_IN_AID =          :fcerm_gia,
      LOCAL_LEVY =            :local_levy,
      GROWTH_FUNDING =        :growth_funding,
      PUBLIC_CONTRIBUTIONS =  :public_contributions,
      PRIVATE_CONTRIBUTIONS = :private_contributions,
      EA_CONTRIBUTIONS =      :other_ea_contributions,
      INTERNAL_DRAINAGE =     :internal_drainage_boards,
      NOT_IDENTIFIED =        :not_yet_identified
    ].freeze

    # These funding sources are stored as separeate records for each contributor
    # rather than a single total. They therefore need summing to get to the total.
    AGGREGATE_SOURCES = [
      PUBLIC_CONTRIBUTIONS,
      PRIVATE_CONTRIBUTIONS,
      EA_CONTRIBUTIONS
    ].freeze

    FUNDING_SOURCES.each do |fs|
      delegate fs, "#{fs}=", "#{fs}?", to: :project
    end

    def current_funding_values
      funding_values.select { |fv| fv.financial_year <= project_end_financial_year }.sort_by(&:financial_year)
      # if this is a db query we lose inputted data when there are errors
      # and we send the user back to fix it
      # It also breaks validating that every column has at least one value overall
      # funding_values.to_financial_year(project_end_financial_year)
    end

    def selected_funding_sources
      FUNDING_SOURCES.select { |s| project.public_send "#{s}?" }
    end

    def unselected_funding_sources
      FUNDING_SOURCES - selected_funding_sources
    end

    def total_for(fs)
      current_funding_values.reduce(0) { |sum, fv| sum + fv.send("#{fs}_total") }
    end

    def grand_total
      selected_funding_sources.reduce(0) { |sum, fs| sum + total_for(fs) }
    end

    def funding_source_label(fs)
      I18n.t(fs, scope: "funding_sources")
    end

    def clean_unselected_funding_sources
      funding_values.each do |fv|
        if fv.financial_year > project_end_financial_year
          fv.destroy
        else
          unselected_funding_sources.each do |fs|
            if FundingSources::AGGREGATE_SOURCES.include?(fs)
              fv.send("#{fs}=", [])
            else
              fv.send("#{fs}=", nil)
            end
          end
        end
      end
    end
  end
end
