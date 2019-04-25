# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::PublicContributorsStep, type: :model do
  subject { FactoryBot.build(:public_contributors_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "requires :public_contributor_names to be present" do
      subject.public_contributor_names = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:public_contributor_names]).to include "^Tell us the public sector contributors."
    end
  end

  describe "#update" do
    subject { FactoryBot.create(:public_contributors_step) }
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

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
