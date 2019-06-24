# frozen_string_literal: true

module PafsCore
  class FundingValuesStep < BasicStep
    include PafsCore::FundingSources
    include PafsCore::FundingValues
    include PafsCore::FinancialYear

    # This sorts the sources with the aggregated sources at the end of the array
    SORTED_SOURCES = (FUNDING_SOURCES - AGGREGATE_SOURCES) + AGGREGATE_SOURCES

    def update(params)
      clean_unselected_funding_sources
      super
    end

    # override to allow us to set up the funding_values if needed
    def before_view(params)
      setup_funding_values
    end

    def sorted_sources
      SORTED_SOURCES & selected_funding_sources
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:funding_values_step).permit(
        funding_values_attributes:
        [
          :id,
          :financial_year,
          :total
        ].concat(FUNDING_SOURCES - AGGREGATE_SOURCES)
      )
    end
  end
end
