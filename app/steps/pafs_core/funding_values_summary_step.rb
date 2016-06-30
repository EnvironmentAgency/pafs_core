# frozen_string_literal: true
module PafsCore
  class FundingValuesSummaryStep < BasicStep
    delegate :fcerm_gia?,
             :local_levy?,
             :internal_drainage_boards?,
             :public_contributions?,
             :private_contributions?,
             :other_ea_contributions?,
             :growth_funding?,
             :not_yet_identified?,
             :project_end_financial_year,
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

    def current_funding_values
      funding_values.select { |fv| fv.financial_year <= project_end_financial_year }.sort_by(&:financial_year)
      # if this is a db query we lose inputted data when there are errors
      # and we send the user back to fix it
      # It also breaks validating that every column has at least one value overall
      # funding_values.to_financial_year(project_end_financial_year)
    end

    # overridden to conditionally enable access to this page
    def disabled?
      # we need the project end financial year and at least one funding source
      project_end_financial_year.nil? || selected_funding_sources.empty?
    end

    def selected_funding_sources
      PafsCore::FUNDING_SOURCES.select { |s| send "#{s}?" }
    end

    def total_for(fs)
      current_funding_values.reduce(0) { |sum, fv| sum + (fv.send(fs) || 0) }
    end

    def grand_total
      selected_funding_sources.reduce(0) { |sum, fs| sum + total_for(fs) }
    end
  end
end
