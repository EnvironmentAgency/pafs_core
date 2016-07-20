# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::PublicContributorsStep, type: :model do
  subject { FactoryGirl.build(:public_contributors_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "requires :public_contributor_names to be present" do
      subject.public_contributor_names = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:public_contributor_names]).to include "^Tell us the public sector contributors."
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:public_contributors_step) }
    let(:params) {
      HashWithIndifferentAccess.new(
        { public_contributors_step: {
            public_contributor_names: "Chigley District Council" }
        }
      )
    }
    let(:error_params) {
      HashWithIndifferentAccess.new(
        { public_contributors_step: {
            public_contributor_names: nil }
        }
      )
    }

    it "saves the state of valid params" do
      expect(subject.update(params)).to eq true
      expect(subject.public_contributor_names).to eq "Chigley District Council"
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :public_contributors
      subject.update(params)
      expect(subject.step).to eq :funding_values
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :public_contributors
      subject.update(error_params)
      expect(subject.step).to eq :public_contributors
    end
  end

  describe "#completed?" do
    context "when valid?" do
      context "when :private_contributions? is true" do
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
        subject.public_contributor_names = nil
        expect(subject.completed?).to eq false
      end
    end
  end

  describe "#is_current_step?" do
    context "when given :funding_sources" do
      it "returns true" do
        expect(subject.is_current_step?(:funding_sources)).to eq true
      end
    end
    context "when not given :funding_sources" do
      it "returns false" do
        expect(subject.is_current_step?(:broccoli)).to eq false
      end
    end
  end

  describe "#previous_step" do
    it "should return :key_dates" do
      expect(subject.previous_step).to eq :key_dates
    end
  end
end