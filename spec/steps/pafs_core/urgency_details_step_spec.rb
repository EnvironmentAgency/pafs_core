# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::UrgencyDetailsStep, type: :model do
  before(:each) do
    @project = FactoryGirl.build(:urgency_details_step)
    # required to be valid
    @project.project.update_attributes(urgency_reason: "health_and_safety")
    @project.project.save
  end

  subject { @project }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :urgency_details is present" do
      subject.urgency_details = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:urgency_details]).to include "can't be blank"
    end
  end

  describe "#update" do
    let(:params) do
      HashWithIndifferentAccess.new({
        urgency_details_step: {
          urgency_details: "Hamster, peas and chips"
        }
      })
    end

    let(:error_params) do
      HashWithIndifferentAccess.new({
        urgency_details_step: {
          urgency_details: ""
        }
      })
    end

    it "saves the :urgency_details when valid" do
      expect(subject.urgency_details).not_to eq "Hamster, peas and chips"
      expect(subject.update(params)).to be true
      expect(subject.urgency_details).to eq "Hamster, peas and chips"
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :urgency_details
      subject.update(params)
      expect(subject.step).to eq :funding_calculator
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :urgency_details
      subject.update(error_params)
      expect(subject.step).to eq :urgency_details
    end
  end

  describe "#previous_step" do
    it "should return :urgency" do
      expect(subject.previous_step).to eq :urgency
    end
  end

  describe "#is_current_step?" do
    it "returns true in response to :urgency" do
      expect(subject.is_current_step?(:urgency)).to eq true
    end
  end
end
