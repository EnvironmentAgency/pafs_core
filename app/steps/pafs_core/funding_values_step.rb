# frozen_string_literal: true
module PafsCore
  class FundingValuesStep < BasicStep
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
             :funding_values=,
             :funding_values_attributes=,
             to: :project

    validate :at_least_one_value_per_column_entered

    def update(params)
      # if javascript is not enabled then we need to show the totals
      # as the next page after successfully saving
      js_enabled = !!params.fetch(:js_enabled, false)
      result = false
      clean_unselected_funding_sources

      assign_attributes(step_params(params))
      if valid? && project.save
        @step = if js_enabled
                  :earliest_start
                else
                  :funding_values_summary
                end
        result = true
      end
      result
    end

    def previous_step
      :funding_sources
    end

    def step
      @step ||= :funding_values
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

    def unselected_funding_sources
      PafsCore::FUNDING_SOURCES - selected_funding_sources
    end

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
        ].concat(PafsCore::FUNDING_SOURCES)
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

    def current_financial_year
      date = Time.zone.today
      date.month < 4 ? (date.year - 1) : date.year
    end

    def at_least_one_value_per_column_entered
      selected_funding_sources.each do |fs|
        found = false
        funding_values.each do |fv|
          val = fv.send(fs)
          if val.present?
            found = true
            errors.add(:base, "Values must be greater than or equal to zero") if val.to_i < 0
          end
        end
        errors.add(:base, "Please enter a value for #{funding_source_name(fs)}") unless found
      end
    end

    def funding_source_name(fs)
      I18n.t("#{fs}_label", scope: "pafs_core.projects.steps.funding_values")
    end
  end
end
