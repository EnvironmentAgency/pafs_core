# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::KeyDatesStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:key_dates_step) }

    it_behaves_like "a project step"

    it "should validate presence of the date attributes with custom message" do
      [:start_outline_business_case_month, :start_outline_business_case_year,
       :award_contract_month, :award_contract_year,
       :start_construction_month, :start_construction_year,
       :ready_for_service_month, :ready_for_service_year].each do |attr|
        should validate_presence_of(attr).with_message("cannot be blank")
      end
    end

    it "validates that the month fields cannot have a value less than 1" do
      [:start_outline_business_case_month,
       :award_contract_month,
       :start_construction_month,
       :ready_for_service_month].each do |attr|
        subject.send("#{attr}=", 0)
        expect(subject.valid?).to be false
        expect(subject.errors.messages[attr]).to include "must be in the range 1 to 12"
      end
    end

    it "validates that the month fields cannot have a value greater than 12" do
      [:start_outline_business_case_month,
       :award_contract_month,
       :start_construction_month,
       :ready_for_service_month].each do |attr|
        subject.send("#{attr}=", 13)
        expect(subject.valid?).to be false
        expect(subject.errors.messages[attr]).to include "must be in the range 1 to 12"
      end
    end

    it "validates that the year fields cannot have a value less than 2000" do
      [:start_outline_business_case_year,
       :award_contract_year,
       :start_construction_year,
       :ready_for_service_year].each do |attr|
        subject.send("#{attr}=", 1999)
        expect(subject.valid?).to be false
        expect(subject.errors.messages[attr]).to include "must be in the range 2000 to 2099"
      end
    end

    it "validates that the year fields cannot have a value greater than 2099" do
      [:start_outline_business_case_year,
       :award_contract_year,
       :start_construction_year,
       :ready_for_service_year].each do |attr|
        subject.send("#{attr}=", 2100)
        expect(subject.valid?).to be false
        expect(subject.errors.messages[attr]).to include "must be in the range 2000 to 2099"
      end
    end

    it "validates that :ready_for_service date cannot be before :start_construction date" do
      subject.ready_for_service_year = subject.start_construction_year - 1
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:ready_for_service_year]).
        to include "can't be earlier than start of construction date"
      subject.ready_for_service_year = subject.start_construction_year
      expect(subject.valid?).to be true
      subject.ready_for_service_month = subject.start_construction_month - 1
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:ready_for_service_year]).
        to include "can't be earlier than start of construction date"
    end

    it "validates that :start_construction date cannot be before :award_contract date" do
      subject.start_construction_year = subject.award_contract_year - 1
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:start_construction_year]).
        to include "can't be earlier than award of contract date"
      subject.start_construction_year = subject.award_contract_year
      expect(subject.valid?).to be true
      subject.start_construction_month = subject.award_contract_month - 1
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:start_construction_year]).
        to include "can't be earlier than award of contract date"
    end

    it "validates that :award_contract date cannot be before :outline_business_case date" do
      subject.award_contract_year = subject.start_outline_business_case_year - 1
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:award_contract_year]).
        to include "can't be earlier than the start of the outline business case date"
      subject.award_contract_year = subject.start_outline_business_case_year
      expect(subject.valid?).to be true
      subject.award_contract_month = subject.start_outline_business_case_month - 1
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:award_contract_year]).
        to include "can't be earlier than the start of the outline business case date"
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:key_dates_step) }
    let(:params) { HashWithIndifferentAccess.new({ key_dates_step: { ready_for_service_year: "2020" }})}
    let(:error_params) { HashWithIndifferentAccess.new({ key_dates_step: { award_contract_month: "83" }})}

    it "saves the key date fields when valid" do
      [:start_outline_business_case_month, :start_outline_business_case_year,
       :award_contract_month, :award_contract_year,
       :start_construction_month, :start_construction_year,
       :ready_for_service_month, :ready_for_service_year].each do |attr|
        new_val = subject.send(attr) + 1
        expect(subject.update({key_dates_step: { attr => new_val }})).to be true
        expect(subject.send(attr)).to eq new_val
      end
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :key_dates
      subject.update(params)
      expect(subject.step).to eq :funding_sources
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :key_dates
      subject.update(error_params)
      expect(subject.step).to eq :key_dates
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:key_dates_step) }

    it "should return :financial_year" do
      expect(subject.previous_step).to eq :financial_year
    end
  end
end
