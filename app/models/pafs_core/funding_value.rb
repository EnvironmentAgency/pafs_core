# frozen_string_literal: true
module PafsCore
  class FundingValue < ActiveRecord::Base
    belongs_to :project
    validates :fcerm_gia,
              :local_levy,
              :internal_drainage_boards,
              :public_contributions,
              :private_contributions,
              :other_ea_contributions,
              :growth_funding,
              :not_yet_identified,
              numericality: true, allow_blank: true

    before_save :update_total

    def self.previous_years
      where(financial_year: -1)
    end

    def self.to_financial_year(year)
      where(arel_table[:financial_year].lteq(year.to_i)).order(:financial_year)
    end

    private
    def update_total
      self.total = PafsCore::FundingSources::FUNDING_SOURCES.reduce(0) do |tot, f|
        v = send(f)
        if v.present?
          tot + v.to_i
        else
          tot
        end
      end
    end
  end
end
