# frozen_string_literal: true

require "rails_helper"

describe PafsCore::FundingContributorsStep, type: :model do
  subject { described_class.new(project) }

  let!(:project) do
    create(
      :project,
      :with_funding_values,
      project_end_financial_year: 2020,
      public_contributions: true,
      public_contribution_names: ["EnviroCo Ltd", "CWI"]
    )
  end

  let(:perform) { subject.update(ActionController::Parameters.new(params)) }
  let(:params) { { name: contributor_names } }

  context "when no contributors have been set (new project)" do
    let!(:project) { create(:project, project_end_financial_year: 2020) }
    let(:contributor_names) { {} }

    it_behaves_like "a project step"

    it "initializes with a single empty name" do
      expect(subject.current_funding_contributors).to eql([""])
    end

    it "requires at least one contributor to be set" do
      expect(perform).to be_falsey
    end
  end

  context "not changing the selected contributors" do
    let(:contributor_names) do
      {
        "0" => { previous: project.funding_contributors.first.name, current: project.funding_contributors.first.name },
        "1" => { previous: project.funding_contributors.last.name, current: project.funding_contributors.last.name }
      }
    end

    it "does not change any funding contributor records" do
      expect do
        perform
      end.not_to change { PafsCore::FundingContributor.order(:id).to_json }
    end
  end

  context "removing a funding contributor" do
    let(:contributor_names) do
      {
        "0" => { previous: project.funding_contributors.first.name, current: project.funding_contributors.first.name }
      }
    end

    it "removes the contributor to all funding values" do
      expect do
        perform
      end.to change(PafsCore::FundingContributor, :count).by(-1 * project.funding_values.count)
    end
  end

  context "adding a funding contributor" do
    let!(:project) do
      create(
        :project,
        :with_funding_values,
        project_end_financial_year: 2020,
        public_contributions: true,
        public_contribution_names: ["Enviro Co"]
      )
    end

    let(:contributor_names) do
      {
        "0" => { previous: project.funding_contributors.first.name, current: project.funding_contributors.first.name },
        "1" => { previous: "", current: "CWI" }
      }
    end

    let(:funding_value) { project.funding_values.first }

    it "adds the contributor to a correct funding value" do
      expect do
        perform
      end.to change(funding_value.funding_contributors, :count).by(1)
    end

    it "adds the contributor to all funding values" do
      expect do
        perform
      end.to change(PafsCore::FundingContributor, :count).by(project.funding_values.count)
    end
  end

  context "changing a funding contributor" do
    let(:contributor_names) do
      {
        "0" => { previous: project.funding_contributors.first.name, current: project.funding_contributors.first.name },
        "1" => { previous: project.funding_contributors.last.name, current: "Clean Water Initiative" }
      }
    end

    it "does not create or delete any funding contributors" do
      expect do
        perform
      end.not_to change { PafsCore::FundingContributor.all.map(&:id).sort }
    end

    it "updates the names of the contributors" do
      expect do
        perform
      end.to change { PafsCore::FundingContributor.all.order(:id).map(&:name).uniq }.from(
        ["EnviroCo Ltd", "CWI"]
      ).to(
        ["EnviroCo Ltd", "Clean Water Initiative"]
      )
    end
  end
end
