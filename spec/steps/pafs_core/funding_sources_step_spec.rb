# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FundingSourcesStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:funding_sources_step) }

    it_behaves_like "a project step"

    it "validates that at least one funding source is selected" do
      subject.fcerm_gia = false
      subject.public_contributions = false
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "You must select at least one funding source"
    end

    it "requires :public_contributor_names to be present when :public_contributions is selected" do
      subject.public_contributions = true
      subject.public_contributor_names = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:public_contributor_names]).to include "can't be blank"
    end

    it "requires :private_contributor_names to be present when :private_contributions is selected" do
      subject.private_contributions = true
      subject.private_contributor_names = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:private_contributor_names]).to include "can't be blank"
    end

    it "requires :other_ea_contributor_names to be present when :other_ea_contributions is selected" do
      subject.other_ea_contributions = true
      subject.other_ea_contributor_names = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:other_ea_contributor_names]).to include "can't be blank"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:funding_sources_step) }
    let(:params) {
      HashWithIndifferentAccess.new(
        { funding_sources_step: {
            private_contributions: "1",
            private_contributor_names: "Acme Corp." }
        }
      )
    }
    let(:error_params) {
      HashWithIndifferentAccess.new(
        { funding_sources_step: {
            private_contributions: "1",
            private_contributor_names: nil }
        }
      )
    }

    it "saves the state of valid params" do
      expect(subject.update(params)).to be true
      expect(subject.private_contributions).to be true
      expect(subject.private_contributor_names).to eq "Acme Corp."
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :funding_sources
      subject.update(params)
      expect(subject.step).to eq :funding_values
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :funding_sources
      subject.update(error_params)
      expect(subject.step).to eq :funding_sources
    end
  end

  describe "#completed?" do
    subject { FactoryGirl.build(:funding_sources_step) }
    context "when valid? and :funding_sources_visited is true" do
      it "returns true" do
        expect(subject.completed?).to eq true
      end
    end

    context "when valid? and :funding_sources_visited is false" do
      it "returns false" do
        subject.funding_sources_visited = false
        expect(subject.completed?).to eq false
      end
    end

    context "when invalid?" do
      it "returns false" do
        subject.project.fcerm_gia = nil
        subject.project.public_contributions = nil
        expect(subject.completed?).to eq false
      end
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:funding_sources_step) }

    it "should return :key_dates" do
      expect(subject.previous_step).to eq :key_dates
    end
  end
end
