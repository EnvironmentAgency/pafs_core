require 'rails_helper'

RSpec.describe PafsCore::Mapper::FundingSources do
  subject { described_class.new(project: project) }

  let(:project) do
    (FactoryBot.create(:full_project, funding_values: [FactoryBot.create(:full_funding_values)]))
  end

  describe '#attributes' do
    let(:expected_public_contributions) { HashWithIndifferentAccess.new(project.public_contributor_names) }
    let(:expected_private_contributions) { HashWithIndifferentAccess.new(project.private_contributor_names) }
    let(:expected_other_ea_contributions) { HashWithIndifferentAccess.new(project.other_ea_contributor_names) }

    let(:expected_funding_values) do
      {
        values: project.funding_values.order(:financial_year).collect do |values|
          {
            financial_year: values.financial_year,
            fcerm_gia: values.fcerm_gia,
            local_levy: values.local_levy,
            internal_drainage_boards: values.internal_drainage_boards,
            public_contributions: values.public_contributions,
            private_contributions: values.private_contributions,
            other_ea_contributions: values.other_ea_contributions,
            growth_funding: values.growth_funding,
            not_yet_identified: values.not_yet_identified
          }
        end
      }
    end

    it "contains public contributions" do
      expect(subject.attributes).to include(expected_public_contributions)
    end

    it "contains private contributions" do
      expect(subject.attributes).to include(expected_private_contributions)
    end

    it "contains other EA contributions" do
      expect(subject.attributes).to include(expected_other_ea_contributions)
    end

    it "contains funding source values" do
      expect(subject.attributes[:funding_sources]).to include(expected_funding_values)
    end
  end
end
