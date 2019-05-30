# frozen_string_literal: true

module PafsCore
  class FundingValuesStep < BasicStep
    include PafsCore::FundingSources
    include PafsCore::FundingValues
    include PafsCore::FinancialYear

    validate :at_least_one_value_per_column_entered

    def update(params)
      clean_unselected_funding_sources
      super
    end

    # override to allow us to set up the funding_values if needed
    def before_view(params)
      setup_funding_values
    end

  private
    def step_params(params)
      ActionController::Parameters.new(params).require(:funding_values_step).permit(
        funding_values_attributes:
        [
          :id,
          :financial_year,
          :total
        ].concat(FUNDING_SOURCES)
      )
    end

    def at_least_one_value_per_column_entered
      if selected_funding_sources.empty?
        # this is only for the nav so we don't get a tick when no funding sources
        # have been selected yet
        errors.add(:base, "You must select at least one funding source first")
      else
        selected_funding_sources.each do |fs|
          found = false
          funding_values.each do |fv|
            val = fv.send(fs)
            if val.present?
              found = true
              errors.add(:base, "Values must be greater than or equal to zero") if val.to_i < 0
            end
          end
          errors.add(
            :base, "In the applicable year(s), tell us the estimated spend for #{funding_source_label(fs)}"
          ) unless found
        end
      end
    end
  end
end
