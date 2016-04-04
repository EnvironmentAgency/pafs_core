# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::Project, type: :model do
  describe "attributes" do
    subject { FactoryGirl.create(:project) }

    it { is_expected.to validate_presence_of :reference_number }

    it { is_expected.to validate_presence_of :version }

    it { is_expected.to validate_uniqueness_of(:reference_number).scoped_to :version }

    it "returns a parmeterized :reference_number as a URL slug" do
      expect(subject.to_param).to eq(subject.reference_number.parameterize.upcase)
    end

    it "validates the format of :reference_number" do
      subject.reference_number = "123"
      expect(subject.valid?).to be false
      expect(subject.errors[:reference_number].join).to match /invalid format/
    end
  end
end
