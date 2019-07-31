# frozen_string_literal: true

module PafsCore::Spreadsheet::Contributors
  class Contributor
    def self.import(row)
      new(*row).tap(&:perform)
    end

    attr_accessor :reference_number, :name, :contributor_type, :financial_year, :amount, :secured, :constrained

    def initialize(reference_number, name, contributor_type, financial_year, amount, secured, constrained)
      @reference_number = reference_number
      @name = name
      @contributor_type = Coerce::ContributorType.perform(contributor_type)
      @financial_year = Coerce::FinancialYear.perform(financial_year)
      @amount = amount
      @secured = Coerce::Boolean.perform(secured)
      @constrained = Coerce::Boolean.perform(constrained)
    end

    def perform
      funding_contributor.update_attributes!(
        amount: amount,
        secured: secured,
        constrained: constrained,
      )
    end

    def project
      @project ||= PafsCore::Project.find_by!(reference_number: reference_number)
    end

    def funding_value
      @funding_value ||= project.funding_values.find_or_initialize_by(
        financial_year: financial_year,
      )
    end

    def funding_contributor
      @funding_contributor ||= funding_value.funding_contributors.find_or_initialize_by(
        contributor_type: contributor_type,
        name: name
      )
    end
  end
end

