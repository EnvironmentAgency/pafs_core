# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::KeyDatesStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:key_dates_step) }

    it_behaves_like "a project step"
  end

  describe "#step" do
    subject { FactoryGirl.build(:key_dates_step) }

    it "should return :key_dates" do
      expect(subject.step).to eq :key_dates
    end
  end
end
