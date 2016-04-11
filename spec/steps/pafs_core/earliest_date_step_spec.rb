# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
require_relative "./shared_step_spec"

RSpec.describe PafsCore::EarliestDateStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:earliest_date_step) }

    it_behaves_like "a project step"

    it "validates that :earliest_start_month is present" do
      subject.earliest_start_month = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_month]).to include "cannot be blank"
    end

    it "validates that :earliest_start_month is greater than 0" do
      subject.earliest_start_month = 0
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_month]).to include "must be in the range 1-12"
    end

    it "validates that :earliest_start_month is less than 13" do
      subject.earliest_start_month = 13
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_month]).to include "must be in the range 1-12"
    end

    it "validates that :earliest_start_year is present" do
      subject.earliest_start_year = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_year]).to include "cannot be blank"
    end

    it "validates that :earliest_start_year is greater than 1999" do
      subject.earliest_start_year = 1999
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_year]).to include "must be in the range 2000-2099"
    end

    it "validates that :earliest_start_year is less than 2100" do
      subject.earliest_start_year = 2100
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:earliest_start_year]).to include "must be in the range 2000-2099"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:earliest_date_step) }
    let(:valid_params) {
      HashWithIndifferentAccess.new(
        { earliest_date_step:
          { earliest_start_month: "11", earliest_start_year: "2016"}
        })}
    let(:error_params) {
      HashWithIndifferentAccess.new(
        { earliest_date_step:
          { earliest_start_month: "13" }
        })}

    it "saves the date params when valid" do
      expect(subject.update(valid_params)).to be true
      expect(subject.earliest_start_month).to eq 11
      expect(subject.earliest_start_year).to eq 2016
    end

    it "updates the next step to :location after a successful update" do
      expect(subject.update(valid_params)).to be true
      expect(subject.step).to eq :location
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to be false
    end

    it "does not change the next step when validation fails" do
      expect(subject.update(error_params)).to be false
      expect(subject.step).to eq :earliest_date
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:earliest_date_step) }

    it "should return :earliest_start" do
      expect(subject.previous_step).to eq :earliest_start
    end
  end
end
