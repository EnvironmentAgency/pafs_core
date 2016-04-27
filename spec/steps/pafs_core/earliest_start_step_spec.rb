# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::EarliestStartStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:earliest_start_step) }

    it_behaves_like "a project step"

    it "validates that :could_start_early has been set" do
      subject.could_start_early = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:could_start_early]).to include "You must select either yes or no"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:earliest_start_step) }
    let(:true_params) { HashWithIndifferentAccess.new({ earliest_start_step: { could_start_early: "true"}})}
    let(:false_params) { HashWithIndifferentAccess.new({ earliest_start_step: { could_start_early: "false"}})}
    let(:error_params) { HashWithIndifferentAccess.new({ earliest_start_step: { could_start_early: nil }})}

    it "saves the :could_start_early when valid" do
      expect(subject.update(true_params)).to be true
      expect(subject.could_start_early).to be true
    end

    it "updates the next step to :earliest_date if :could_start_early is true" do
      expect(subject.update(true_params)).to be true
      expect(subject.step).to eq :earliest_date
    end

    it "updates the next step to :location if :could_start_early is false" do
      expect(subject.update(false_params)).to be true
      expect(subject.step).to eq :location
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to be false
    end

    it "does not change the next step when validation fails" do
      expect(subject.update(error_params)).to be false
      expect(subject.step).to eq :earliest_start
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:earliest_start_step) }

    it "should return :funding_sources" do
      expect(subject.previous_step).to eq :funding_sources
    end
  end

  describe "#completed?" do
    subject { FactoryGirl.build(:earliest_start_step) }

    it "should return false when :could_start_early nil" do
      subject.could_start_early = nil
      expect(subject.completed?).to be false
    end

    it "should return false when EarliestDateStep sub-task not completed" do
      expect(subject.completed?).to be false
    end

    it "should return true when EarliestDateStep sub-task completed" do
      subject.project.earliest_start_month = 10
      subject.project.earliest_start_year = 2017
      expect(subject.completed?).to be true
    end
  end
end
