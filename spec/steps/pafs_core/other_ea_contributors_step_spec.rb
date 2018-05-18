# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::OtherEaContributorsStep, type: :model do
  subject { FactoryGirl.build(:other_ea_contributors_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "requires :other_ea_contributor_names to be present" do
      subject.other_ea_contributor_names = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:other_ea_contributor_names]).
        to include "^Tell us about the expected contributions from other Environment Agency functions or sources."
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:other_ea_contributors_step) }
    let(:params) {
      HashWithIndifferentAccess.new(
        { other_ea_contributors_step: {
            other_ea_contributor_names: "Chigley Water" }
        }
      )
    }
    let(:error_params) {
      HashWithIndifferentAccess.new(
        { other_ea_contributors_step: {
            other_ea_contributor_names: nil }
        }
      )
    }

    it "saves the state of valid params" do
      expect(subject.update(params)).to eq true
      expect(subject.other_ea_contributor_names).to eq "Chigley Water"
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
