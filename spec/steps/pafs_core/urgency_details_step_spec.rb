# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::UrgencyDetailsStep, type: :model do
  before(:each) do
    @project = FactoryBot.build(:urgency_details_step)
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
      expect(subject.errors.messages[:urgency_details]).to include
      "^You told us the project is urgent due to a health and safety issue. Tell us more information about this."
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

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
