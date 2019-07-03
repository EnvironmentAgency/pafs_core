# frozen_string_literal: true

module PafsCore
  class FundingValuesStep < BasicStep
    include PafsCore::FundingSources
    include PafsCore::FundingValues
    include PafsCore::FinancialYear

    # This sorts the sources with the aggregated sources at the end of the array
    SORTED_SOURCES = (FUNDING_SOURCES - AGGREGATE_SOURCES) + AGGREGATE_SOURCES

    validate :at_least_one_value

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

    def funding_values_to_check
      selected_funding_sources - AGGREGATE_SOURCES
    end

    def at_least_one_value
      values = funding_values.map {|x| x.attributes.slice(*funding_values_to_check.map(&:to_s))}
      zero_valued = values.inject({}) do |a, e| 
        e.each do |k, v| 
          if a.key?(k)
            a[k] = a[k].to_i + v.to_i
          else
            a[k] = v.to_i
          end
        end
        a
      end.select {|k, v| v == 0 }

      return if zero_valued.empty?

      errors.add(:base, "Please ensure at least one value is added for each funding source")
      false
    end

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
