# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ApproachStep, type: :model do
  subject { FactoryGirl.build(:approach_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :approach is present" do
      subject.approach = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:approach]).to include "^Please enter a description"
    end
  end

  describe "#update" do
    let(:params) do
      HashWithIndifferentAccess.new({
        approach_step: {
          approach: "Wigwam on toast"
        }
      })
    end

    let(:error_params) do
      HashWithIndifferentAccess.new({
        approach_step: {
          approach: ""
        }
      })
    end

    it "saves the :approach when valid" do
      expect(subject.approach).not_to eq "Wigwam on toast"
      expect(subject.update(params)).to be true
      expect(subject.approach).to eq "Wigwam on toast"
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :approach
      subject.update(params)
      expect(subject.step).to eq :surface_and_groundwater
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :approach
      subject.update(error_params)
      expect(subject.step).to eq :approach
    end
  end

  describe "#previous_step" do
    it "should return :urgency" do
      expect(subject.previous_step).to eq :standard_of_protection
    end
  end
end
