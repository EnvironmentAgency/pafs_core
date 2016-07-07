# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::UrgencyStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:urgency_step) }

    it_behaves_like "a project step"

    it "validates that :urgency_reason is present" do
      subject.urgency_reason = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:urgency_reason]).to include "^Please select the reason for the urgency"
    end

    it "validates that the selected :urgency_reason is valid" do
      PafsCore::URGENCY_REASONS.each do |r|
        subject.urgency_reason = r
        expect(subject.valid?).to be true
      end
      subject.urgency_reason = "wigwam_peanut"
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:urgency_reason]).to include "^Please select the reason for the urgency"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:urgency_step) }
    let(:params) { HashWithIndifferentAccess.new({ urgency_step: { urgency_reason: "legal_need" }})}
    let(:error_params) { HashWithIndifferentAccess.new({ urgency_step: { urgency_reason: "ABC" }})}

    it "saves the :urgency_reason when valid" do
      expect(subject.urgency_reason).not_to eq "legal_need"
      expect(subject.update(params)).to be true
      expect(subject.urgency_reason).to eq "legal_need"
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :urgency
      subject.update(params)
      expect(subject.step).to eq :urgency_details
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :urgency
      subject.update(error_params)
      expect(subject.step).to eq :urgency
    end

    context "when not urgent selected" do
      let(:params) { HashWithIndifferentAccess.new({ urgency_step: { urgency_reason: "not_urgent" }})}
      it "sets the next step to :funding_calculator" do
        expect(subject.step).to eq :urgency
        subject.update(params)
        expect(subject.step).to eq :funding_calculator
      end
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:urgency_step) }

    it "should return :remove_fish_barrier" do
      expect(subject.previous_step).to eq :remove_fish_barrier
    end
  end

  describe "#completed?" do
    subject { FactoryGirl.build(:urgency_step) }

    it "should return false when not valid" do
      subject.urgency_reason = nil
      expect(subject.completed?).to be false
    end

    context "when urgent" do
      it "should return false when UrgencyDetailsStep sub-task not completed" do
        expect(subject.completed?).to be false
      end

      it "should return true when UrgencyDetailsStep sub-task completed" do
        subject.project.urgency_details = "These are the details"
        expect(subject.completed?).to be true
      end
    end

    context "when not urgent" do
      before(:each) do
        subject.urgency_reason = "not_urgent"
      end

      it "should return true when valid" do
        expect(subject.completed?).to be true
      end
    end
  end
end
