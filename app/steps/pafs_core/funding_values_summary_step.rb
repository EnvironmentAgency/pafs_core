# frozen_string_literal: true
module PafsCore
  class FundingValuesSummaryStep < BasicStep
    include PafsCore::FundingSources
    delegate :project_end_financial_year,
             :funding_values,
             to: :project

    def update(params)
      # just progress to next step
      @step = :earliest_start
      true
    end

    def previous_step
      :funding_values
    end

    def step
      @step ||= :funding_values_summary
    end

    # overridden to conditionally enable access to this page
    def disabled?
      # we need the project end financial year and at least one funding source
      project_end_financial_year.nil? || selected_funding_sources.empty?
    end
  end
end
