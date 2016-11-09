# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::UserArea, type: :model do
  describe "attributes" do
    subject { FactoryGirl.create(:user_area) }

    it { is_expected.to_not validate_presence_of :primary }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:area_id) }

    it "validates that :area_id is present" do
      subject.area_id = nil
      expect(subject.valid?).to be false
      expect(subject.errors[:area_id]).to include "^Select an area"
    end
  end
end
