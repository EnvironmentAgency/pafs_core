# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Mapper::FundingSources do
  subject { described_class.new(project: project) }

  let(:funding_values) { [create(:funding_value)] }
  let(:project) { create(:full_project, funding_values: funding_values) }

  describe "#attributes" do
    let(:expected_funding_values) do
      {
        values: project.funding_values.order(:financial_year).collect do |values|
          {
            financial_year: values.financial_year,
            fcerm_gia: values.fcerm_gia,
            local_levy: values.local_levy,
            internal_drainage_boards: values.internal_drainage_boards,
            public_contributions: nil,
            private_contributions: nil,
            other_ea_contributions: nil,
            growth_funding: values.growth_funding,
            not_yet_identified: values.not_yet_identified
          }
        end
      }
    end

    it "contains funding source values" do
      expect(subject.attributes[:funding_sources]).to include(expected_funding_values)
    end
  end
end
