# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::StartConstructionDateStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:start_construction_date_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    let(:project) {
      FactoryGirl.create(
        :project,
        award_contract_month: 1,
        award_contract_year: 2012
      )
    }

    subject { FactoryGirl.create(:start_construction_date_step, project: project) }
    let(:params) {
      HashWithIndifferentAccess.new({
        start_construction_date_step: {
          start_construction_case_year: "2020",
          start_construction_month: "1"
        }
      })
    }

    let(:error_params) {
      HashWithIndifferentAccess.new({
        start_construction_date_step: { start_construction_month: "83" }
      })
    }

    it "saves the start construction fields when valid" do
      [:start_construction_month, :start_construction_year].each do |attr|
        new_val = subject.send(attr) + 1
        expect(subject.update({start_construction_date_step: { attr => new_val }})).to be true
        expect(subject.send(attr)).to eq new_val
      end
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :start_construction_date
      subject.update(params)
      expect(subject.step).to eq :ready_for_service_date
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :start_construction_date
      subject.update(error_params)
      expect(subject.step).to eq :start_construction_date
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:start_construction_date_step) }

    it "should return :award_contract_date" do
      expect(subject.previous_step).to eq :award_contract_date
    end
  end

  describe "#is_current_step?" do
    subject { FactoryGirl.build(:start_construction_date_step) }

    it "should return true for :key_dates" do
      expect(subject.is_current_step?(:key_dates)).to eq true
    end
  end
end
