# frozen_string_literal: true
module PafsCore
  class FundingValuesStep < BasicStep
    include PafsCore::FundingSources, PafsCore::FinancialYear
    delegate :project_end_financial_year,
             :funding_values,
             :funding_values=,
             :funding_values_attributes=,
             to: :project

    validate :at_least_one_value_per_column_entered

    def update(params)
      clean_unselected_funding_sources
      super
    end

    # overridden to conditionally enable access to this page
    # def disabled?
    #   # we need the project end financial year and at least one funding source
    #   project_end_financial_year.nil? || selected_funding_sources.empty?
    # end

    # override to allow us to set up the funding_values if needed
    def before_view
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

    def setup_funding_values
      # need to ensure the project has the right number of funding_values entries
      # for the tables
      # we need at least:
      #   previous years
      #   current financial year to :project_end_financial_year
      years = [-1]
      years.concat((current_financial_year..project_end_financial_year).to_a)
      years.each { |y| build_missing_year(y) }
    end

    def clean_unselected_funding_sources
      funding_values.each do |fv|
        if fv.financial_year > project_end_financial_year
          fv.destroy
        else
          unselected_funding_sources.each do |fs|
            fv.send("#{fs}=", nil)
          end
        end
      end
    end

    def build_missing_year(year)
      funding_values.build(financial_year: year) unless funding_values.exists?(financial_year: year)
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
          errors.add(:base, "Please enter a value for #{funding_source_label(fs)}") unless found
        end
      end
    end
  end
end
