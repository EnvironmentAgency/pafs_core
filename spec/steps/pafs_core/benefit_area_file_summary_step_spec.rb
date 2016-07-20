# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::BenefitAreaFileSummaryStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:benefit_area_file_summary_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    subject { FactoryGirl.create(:benefit_area_file_summary_step) }

    it "updates the next step to benefit_area_file_summary if valid and file has been uploaded" do
      expect(subject.step).to eq :benefit_area_file_summary
      subject.update
      expect(subject.step).to eq :risks
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:benefit_area_file_summary_step) }

    it "should return :key_dates" do
      expect(subject.previous_step).to eq :map
    end
  end

  describe "#is_current_step?" do
    subject { FactoryGirl.build(:benefit_area_file_summary_step) }

    it "should return true for :map" do
      expect(subject.is_current_step?(:map)).to eq true
    end
  end
end
