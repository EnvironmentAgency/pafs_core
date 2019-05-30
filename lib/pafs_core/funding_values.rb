# frozen_string_literal: true

module PafsCore
  module FundingValues
    delegate :project_end_financial_year,
             :funding_values,
             :funding_values=,
             :funding_values_attributes=,
             to: :project

    def build_missing_year(year)
      funding_values.build(financial_year: year) unless funding_values.exists?(financial_year: year)
    end

    def setup_funding_values
      # need to ensure the project has the right number of funding_values entries
      # for the tables
      # we need at least:
      #   previous years
      #   current financial year to :project_end_financial_year
      years = [-1]
      years.concat((2015..project_end_financial_year).to_a)
      years.each { |y| build_missing_year(y) }
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

