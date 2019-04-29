# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::UrgencyStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:urgency_step) }

    it_behaves_like "a project step"

    it "validates that :urgency_reason is present" do
      subject.urgency_reason = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:urgency_reason]).to include
      "^If your project is urgent, select a reason. If it isn't urgent, select the first option."
    end

    it "validates that the selected :urgency_reason is valid" do
      PafsCore::Urgency::URGENCY_REASONS.each do |r|
        subject.urgency_reason = r
        expect(subject.valid?).to be true
      end
      subject.urgency_reason = "wigwam_peanut"
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:urgency_reason]).to include
      "^If your project is urgent, select a reason. If it isn't urgent, select the first option."
    end
  end

  describe "#update" do
    subject { FactoryBot.create(:urgency_step) }
    let(:params) { HashWithIndifferentAccess.new({ urgency_step: { urgency_reason: "legal_need" }})}
    let(:error_params) { HashWithIndifferentAccess.new({ urgency_step: { urgency_reason: "ABC" }})}

    it "saves the :urgency_reason when valid" do
      expect(subject.urgency_reason).not_to eq "legal_need"
      expect(subject.update(params)).to be true
      expect(subject.urgency_reason).to eq "legal_need"
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
