# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::FundingSourcesStep, type: :model do
  subject { FactoryGirl.build(:funding_sources_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that at least one funding source is selected" do
      subject.fcerm_gia = false
      subject.public_contributions = false
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:base]).to include "You must select at least one funding source"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:funding_sources_step) }
    let(:params) {
      HashWithIndifferentAccess.new({ funding_sources_step: { growth_funding: "1" }})
    }
    let(:error_params) {
      HashWithIndifferentAccess.new({ funding_sources_step: { fcerm_gia: nil }})
    }

    it "saves the state of valid params" do
      expect(subject.update(params)).to be true
      expect(subject.growth_funding).to be true
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

  describe "#completed?" do
    context "when valid? and :funding_sources_visited is true" do
      context "when :public_contributions? is true" do
        it "returns result of :public_contributors_step#completed?" do
          subject.project.public_contributions = true
          substep = double("public_contributors")
          expect(substep).to receive(:completed?) { false }
          expect(PafsCore::PublicContributorsStep).to receive(:new) { substep }
          expect(subject.completed?).to eq false
        end
      end

      context "when public_contributions? is false and private_contributions? is true" do
        it "returns result of :private_contributors_step#completed?" do
          subject.project.private_contributions = true
          substep = double("private_contributors")
          expect(substep).to receive(:completed?) { false }
          expect(PafsCore::PrivateContributorsStep).to receive(:new) { substep }
          expect(subject.completed?).to eq false
        end
      end

      context "when :private_contributions? is false and :other_ea_contributions? is true" do
        it "returns result of :other_ea_contributors_step#completed?" do
          subject.project.other_ea_contributions = true
          substep = double("other_ea_contributors")
          expect(substep).to receive(:completed?) { false }
          expect(PafsCore::OtherEaContributorsStep).to receive(:new) { substep }
          expect(subject.completed?).to eq false
        end
      end

      it "returns true" do
        expect(subject.completed?).to eq true
      end
    end

    context "when not valid?" do
      it "returns false" do
        subject.fcerm_gia = nil
        expect(subject.completed?).to eq false
      end
    end

    context "when valid? but :funding_sources_visited? is false" do
      it "returns false" do
        subject.funding_sources_visited = false
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
