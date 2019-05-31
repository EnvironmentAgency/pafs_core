# frozen_string_literal: true

module PafsCore
  class FundingValue < ActiveRecord::Base
    belongs_to :project

    has_many :funding_contributors, dependent: :destroy
    has_many :public_contributions, -> { where(contributor_type: FundingSources::PUBLIC_CONTRIBUTIONS) }, class_name: 'PafsCore::FundingContributor'
    has_many :private_contributions, -> { where(contributor_type: FundingSources::PRIVATE_CONTRIBUTIONS) }, class_name: 'PafsCore::FundingContributor'
    has_many :other_ea_contributions, -> { where(contributor_type: FundingSources::EA_CONTRIBUTIONS) }, class_name: 'PafsCore::FundingContributor'

    validates :fcerm_gia,
              :local_levy,
              :internal_drainage_boards,
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

    FundingSources::FUNDING_SOURCES.each do |source|
      define_method("#{source}_total") do
        return public_send(source).to_i unless FundingSources::AGGREGATE_SOURCES.include?(source)
        (public_send(source) || []).map(&:amount).compact.sum.to_i
      end
    end

    private

    def update_total
      self.total = FundingSources::FUNDING_SOURCES.reduce(0) {|tot, f| tot += public_send("#{f}_total") }
    end
  end
end
