# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::LocationStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:location_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    subject { FactoryGirl.create(:location_step) }
    let(:params) {
      HashWithIndifferentAccess.new({
        location_step: {
          project_location: "[\"444444\", \"222222\"]",
          project_location_zoom_level: 19
        }
      })
    }
    let(:error_params) {
      HashWithIndifferentAccess.new({
        location_step: {
          project_location: nil,
          project_location_zoom_level: nil
        }
      })
    }

    it "saves the :project_location when valid" do
      expect(subject.project_location).not_to eq %w(444444 222222)
      expect(subject.project_location_zoom_level).not_to eq 19
      expect(subject.update(params)).to be true
      expect(subject.project_location).to eq %w(444444 222222)
      expect(subject.project_location_zoom_level).to eq 19
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :location
      subject.update(params)
      expect(subject.step).to eq :map
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :location
      subject.update(error_params)
      expect(subject.step).to eq :location
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:location_step) }

    it "should return :key_dates" do
      expect(subject.previous_step).to eq :key_dates
    end
  end

  describe "#completed?" do
    subject { FactoryGirl.create(:location_step) }

    it "should return completed? correctly" do
      expect(subject.completed?).to eq(true)
      subject.update(location_step: { project_location: "[]"})
      expect(subject.completed?).to eq(false)
    end
  end
end
