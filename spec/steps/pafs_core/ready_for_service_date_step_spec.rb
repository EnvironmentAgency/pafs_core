# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ReadyForServiceDateStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:ready_for_service_date_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    let(:project) {
      FactoryGirl.create(
        :project,
        start_construction_month: 1,
        start_construction_year: 2012
      )
    }

    subject { FactoryGirl.create(:ready_for_service_date_step, project: project) }
    let(:params) {
      HashWithIndifferentAccess.new({
        ready_for_service_date_step: {
          ready_for_service_year: 5.years.from_now.year.to_s,
          ready_for_service_month: "1"
        }
      })
    }

    let(:invalid_month_params) {
      HashWithIndifferentAccess.new({
        ready_for_service_date_step: { ready_for_service_month: "83", ready_for_service_year: "1999" }
      })
    }

    let(:invalid_year_params) {
      HashWithIndifferentAccess.new({
        ready_for_service_date_step: { ready_for_service_month: "12", ready_for_service_year: "2000" }
      })
    }

    let(:invalid_date_params) {
      HashWithIndifferentAccess.new({
        ready_for_service_date_step: { ready_for_service_month: "12", ready_for_service_year: "2013" }
      })
    }

    it "saves the start construction fields when valid" do
      [:ready_for_service_month, :ready_for_service_year].each do |attr|
        new_val = subject.send(attr) + 1
        expect(subject.update({ready_for_service_date_step: { attr => new_val }})).to be true
        expect(subject.send(attr)).to eq new_val
      end
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :ready_for_service_date
      subject.update(params)
      expect(subject.step).to eq :funding_sources
    end

    it "returns false when validation fails" do
      expect(subject.update(invalid_month_params)).to eq false
      expect(subject.update(invalid_year_params)).to eq false
      expect(subject.update(invalid_date_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :ready_for_service_date
      subject.update(invalid_year_params)
      expect(subject.step).to eq :ready_for_service_date
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:ready_for_service_date_step) }

    it "should return :start_construction_date" do
      expect(subject.previous_step).to eq :start_construction_date
    end
  end

  describe "#is_current_step?" do
    subject { FactoryGirl.build(:ready_for_service_date_step) }

    it "should return true for :key_dates" do
      expect(subject.is_current_step?(:key_dates)).to eq true
    end
  end
end
