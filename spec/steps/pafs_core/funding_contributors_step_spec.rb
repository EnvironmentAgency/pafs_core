# frozen_string_literal: true

require "rails_helper"

describe PafsCore::FundingContributorsStep, type: :model, focus: true do
  subject { described_class.new(project) }

  let(:project) do 
    create(
      :project, 
      :with_funding_values, 
      project_end_financial_year: 2020,
      public_contributions: true
    )
  end

  let(:perform) { subject.update(params) }
  let(:params) { { funding_contributors_step: { name: contributor_names} } }

  context 'when no contributors have been set (new project)' do
    let(:project) { create(:project, project_end_financial_year: 2020) }
    let(:contributor_names) { [] }

    it_behaves_like "a project step"

    it 'initializes with a single empty name' do
      expect(subject.current_funding_contributors).to eql([''])
    end

    it 'requires at least one contributor to be set' do
      expect(subject.valid?).to be_falsey
    end
  end

  context 'not changing the selected contributors' do
    let(:contributor_names) { ["EnviroCo Ltd", "CWI"] }
    let(:funding_value) { project.funding_values.first }

    before do
      project.funding_values.each do |fv|
        create(:funding_contributor, funding_value: fv, name: 'EnviroCo Ltd')
        create(:funding_contributor, funding_value: fv, name: 'CWI')
      end

      project.reload
    end

    it 'does not change any funding contributor records' do
      expect do
        perform
      end.not_to change { PafsCore::FundingContributor.order(:id).to_json }
    end
  end

  context 'removing a funding contributor' do
    let(:contributor_names) { ["EnviroCo Ltd"] }
    let(:funding_value) { project.funding_values.first }

    before do
      project.funding_values.each do |fv|
        create(:funding_contributor, funding_value: fv, name: 'EnviroCo Ltd')
        create(:funding_contributor, funding_value: fv, name: 'CWI')
      end

      project.reload
    end

    it 'removes the contributor to a correct funding value' do
      expect do
        perform
      end.to change(funding_value.funding_contributors, :count).by(-1)
    end

    it 'removes the contributor to all funding values' do
      expect do
        perform
      end.to change(PafsCore::FundingContributor, :count).by(-1 * project.funding_values.count)
    end
  end

  context 'adding a funding contributor' do
    let(:contributor_names) { ["EnviroCo Ltd", "CWI"] }
    let(:funding_value) { project.funding_values.first }

    before do
      project.funding_values.each do |fv|
        create(:funding_contributor, funding_value: fv, name: 'EnviroCo Ltd')
      end
    end

    it 'adds the contributor to a correct funding value' do
      expect do
        perform
      end.to change(funding_value.funding_contributors, :count).by(1)
    end

    it 'adds the contributor to all funding values' do
      expect do
        perform
      end.to change(PafsCore::FundingContributor, :count).by(project.funding_values.count)
    end
  end
end
