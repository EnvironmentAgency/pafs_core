# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::DataMigration::MoveFundingSources do
  describe "#perform_all" do
    let!(:project_1) { create(:project) }
    let!(:project_2) { create(:project) }
    let(:migrator) { double(:migrator, perform: true) }

    it "deduplicates all projects" do
      expect(described_class).to receive(:new).with(project_1).and_return(migrator)
      expect(described_class).to receive(:new).with(project_2).and_return(migrator)

      described_class.perform_all
    end
  end

  describe "#perform" do
    let(:project) { create(:project) }
    let(:perform) { described_class.new(project).perform }

    context "with a project that has no funding" do
      it "does not raise an exception" do
        expect do
          perform
        end.not_to raise_exception
      end

      it "creates no funding contributors" do
        expect do
          perform
        end.not_to change { PafsCore::FundingContributor.count }
      end
    end

    context "with a public contributor" do
      before do
        project.update_columns(
          public_contributor_names: "One, Two, Three",
          public_contributions: true
        )

        project.funding_values.create(financial_year: -1).update_column(:public_contributions, 10)
        project.funding_values.create(financial_year: 2015).update_column(:public_contributions, 100)
        project.funding_values.create(financial_year: 2016).update_column(:public_contributions, 1000)
      end

      it "creates a funding_contributor for each financial year" do
        expect do
          perform
        end.to change { PafsCore::FundingContributor.count }.by(3)
      end

      it "correctly calculates the total" do
        perform
        expect(project.total_for_funding_source(:public_contributions)).to eql(1110)
        expect(project.total_for_funding_source(:private_contributions)).to eql(0)
        expect(project.total_for_funding_source(:other_ea_contributions)).to eql(0)
      end

      it "creates the correct number of public contributions" do
        expect do
          perform
        end.to change { project.reload.funding_contributors.where(contributor_type: "public_contributions").count }.by(3)
      end

      it "creates the correct number of private contributions" do
        expect do
          perform
        end.not_to change { project.reload.funding_contributors.where(contributor_type: "private_contributions").count }
      end

      it "creates the correct number of other ea contributions" do
        expect do
          perform
        end.not_to change { project.reload.funding_contributors.where(contributor_type: "other_ea_contributions").count }
      end

      it "sets the funding countributor names" do
        perform
        expect(project.funding_values.first.public_contributions.first.name).to eql("One, Two, Three")
      end
    end

    context "with a private contributor" do
      before do
        project.update_columns(
          private_contributor_names: "One, Two, Three",
          private_contributions: true
        )

        project.funding_values.create(financial_year: -1).update_column(:private_contributions, 10)
        project.funding_values.create(financial_year: 2015).update_column(:private_contributions, 100)
        project.funding_values.create(financial_year: 2016).update_column(:private_contributions, 1000)
      end

      it "creates a funding_contributor for each financial year" do
        expect do
          perform
        end.to change { PafsCore::FundingContributor.count }.by(3)
      end

      it "correctly calculates the total" do
        perform
        expect(project.total_for_funding_source(:public_contributions)).to eql(0)
        expect(project.total_for_funding_source(:private_contributions)).to eql(1110)
        expect(project.total_for_funding_source(:other_ea_contributions)).to eql(0)
      end

      it "creates the correct number of public contributions" do
        expect do
          perform
        end.not_to change { project.reload.funding_contributors.where(contributor_type: "public_contributions").count }
      end

      it "creates the correct number of private contributions" do
        expect do
          perform
        end.to change { project.reload.funding_contributors.where(contributor_type: "private_contributions").count }.by(3)
      end
      it "creates the correct number of other ea contributions" do
        expect do
          perform
        end.not_to change { project.reload.funding_contributors.where(contributor_type: "other_ea_contributions").count }
      end

      it "sets the funding countributor names" do
        perform
        expect(project.funding_values.first.private_contributions.first.name).to eql("One, Two, Three")
      end
    end

    context "with an other ea contributor" do
      before do
        project.update_columns(
          other_ea_contributor_names: "One, Two, Three",
          other_ea_contributions: true
        )

        project.funding_values.create(financial_year: -1).update_column(:other_ea_contributions, 10)
        project.funding_values.create(financial_year: 2015).update_column(:other_ea_contributions, 100)
        project.funding_values.create(financial_year: 2016).update_column(:other_ea_contributions, 1000)
      end

      it "creates a funding_contributor for each financial year" do
        expect do
          perform
        end.to change { PafsCore::FundingContributor.count }.by(3)
      end

      it "correctly calculates the total" do
        perform
        expect(project.total_for_funding_source(:public_contributions)).to eql(0)
        expect(project.total_for_funding_source(:private_contributions)).to eql(0)
        expect(project.total_for_funding_source(:other_ea_contributions)).to eql(1110)
      end

      it "creates the correct number of public contributions" do
        expect do
          perform
        end.not_to change { project.reload.funding_contributors.where(contributor_type: "public_contributions").count }
      end

      it "creates the correct number of private contributions" do
        expect do
          perform
        end.not_to change { project.reload.funding_contributors.where(contributor_type: "private_contributions").count }
      end
      it "creates the correct number of other_ea contributions" do
        expect do
          perform
        end.to change { project.reload.funding_contributors.where(contributor_type: "other_ea_contributions").count }.by(3)
      end

      it "sets the funding countributor names" do
        perform
        expect(project.funding_values.first.other_ea_contributions.first.name).to eql("One, Two, Three")
      end
    end
  end
end
