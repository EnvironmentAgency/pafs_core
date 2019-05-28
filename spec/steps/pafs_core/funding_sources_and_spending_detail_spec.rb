# frozen_string_literal: true

describe PafsCore::Project, type: :model do
  subject do 
    create(
      :project,
      fcerm_gia: true,
      local_levy: true,
      public_contributions: true,
      private_contributions: true,
      other_ea_contributions: true,
      growth_funding: true,
      internal_drainage_boards: true,
      not_yet_identified: true,
      project_end_financial_year: 2022
    )
  end

  let!(:funding_value_1) do
    create(
      :funding_value,
      :with_public_contributor,
      :with_private_contributor,
      :with_other_ea_contributor,
      project: subject,
      financial_year: 2018,
      fcerm_gia: 1000,
      local_levy: 1000,
      growth_funding: 1000,
      internal_drainage_boards: 1000,
      not_yet_identified: 1000
    )
  end

  let!(:funding_value_2) do
    create(
      :funding_value,
      :with_public_contributor,
      :with_private_contributor,
      :with_other_ea_contributor,
      project: subject,
      fcerm_gia: 2000,
      local_levy: 2000,
      growth_funding: 2000,
      internal_drainage_boards: 2000,
      not_yet_identified: 2000
    )
  end

  describe "when spends are available" do
    it "should return the correct totals for the funding sources" do
      expect(subject.total_for_funding_source(:fcerm_gia)).to eq 3000
      expect(subject.total_for_funding_source(:local_levy)).to eq 3000
      expect(subject.total_for_funding_source(:public_contributions)).to eq 2000
      expect(subject.total_for_funding_source(:private_contributions)).to eq 2000
      expect(subject.total_for_funding_source(:other_ea_contributions)).to eq 2000
      expect(subject.total_for_funding_source(:growth_funding)).to eq 3000
      expect(subject.total_for_funding_source(:internal_drainage_boards)).to eq 3000
      expect(subject.total_for_funding_source(:not_yet_identified)).to eq 3000
    end
  end
end
