# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::PrivateContributorsStep, type: :model do
  subject { FactoryGirl.build(:private_contributors_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "requires :private_contributor_names to be present" do
      subject.private_contributor_names = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:private_contributor_names]).to include "^Tell us the private sector contributors."
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:private_contributors_step) }
    let(:params) {
      HashWithIndifferentAccess.new(
        { private_contributors_step: {
            private_contributor_names: "Chigley Imperial Windmills" }
        }
      )
    }
    let(:error_params) {
      HashWithIndifferentAccess.new(
        { private_contributors_step: {
            private_contributor_names: nil }
        }
      )
    }

    it "saves the state of valid params" do
      expect(subject.update(params)).to eq true
      expect(subject.private_contributor_names).to eq "Chigley Imperial Windmills"
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
