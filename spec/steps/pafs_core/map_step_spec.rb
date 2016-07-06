# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::LocationStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:map_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    subject { FactoryGirl.create(:map_step) }
    let(:params) {
      HashWithIndifferentAccess.new({
        map_step: {
          benefit_area: "[[444444, 222222], [421212, 212121], [432123, 234432]]",
          benefit_area_zoom_level: 3,
          benefit_area_centre: "[\"420000\", \"230000\"]"
        }
      })
    }

    let(:error_params) {
      HashWithIndifferentAccess.new({
        map_step: {
          benefit_area_centre: nil,
          benefit_area_zoom_level: nil
        }
      })
    }

    it "saves the :project_location when valid" do
      expect(subject.benefit_area).not_to eq "[[444444, 222222], [421212, 212121], [432123, 234432]]"
      expect(subject.benefit_area_centre).not_to eq %w(420000 230000)
      expect(subject.benefit_area_zoom_level).not_to eq 3
      expect(subject.update(params)).to be true
      expect(subject.benefit_area).to eq "[[444444, 222222], [421212, 212121], [432123, 234432]]"
      expect(subject.benefit_area_centre).to eq %w(420000 230000)
      expect(subject.benefit_area_zoom_level).to eq 3
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :map
      subject.update(params)
      expect(subject.step).to eq :risks
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :map
      subject.update(error_params)
      expect(subject.step).to eq :map
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:map_step) }

    it "should return :key_dates" do
      expect(subject.previous_step).to eq :location
    end
  end

  describe "#completed?" do
    subject { FactoryGirl.build(:map_step) }

    it "returns false with nil or empty benefit area" do
      subject.update(map_step: { benefit_area: ""})
      expect(subject.completed?).to be false
    end

    it "returns true with defined benefit_area" do
      expect(subject.completed?).to be true
    end
  end

  describe "#disabled?" do
    subject { FactoryGirl.build(:map_step) }

    it "should return true if there is no project location" do
      subject.project.update(project_location: "[]")
      expect(subject.disabled?).to be true
    end
  end
end
