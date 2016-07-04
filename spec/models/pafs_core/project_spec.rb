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

  describe "#flooding?" do
    subject { FactoryGirl.create(:project) }

    it "is expected to return true if the project protects against any kind of flooding" do
      subject.fluvial_flooding = true
      expect(subject.flooding?).to eq(true)

      subject.fluvial_flooding = false
      subject.groundwater_flooding = true
      expect(subject.flooding?).to eq(true)

      subject.groundwater_flooding = false
      subject.tidal_flooding = true
      expect(subject.flooding?).to eq(true)

      subject.tidal_flooding = false
      subject.surface_water_flooding = true
      expect(subject.flooding?).to eq(true)

      subject.surface_water_flooding = false
      expect(subject.flooding?).not_to eq(true)
    end
  end

  describe "#project_protects_households?" do
    it "is expecxted to return false if the project does not protect households" do
      subject.project_type = "ENV_WITHOUT_HOUSEHOLDS"

      expect(subject.project_protects_households?).to eq false
    end

    it "is expected to return true if the project does protect households" do
      project_types = PafsCore::PROJECT_TYPES[0...-1]

      project_types.each do |pt|
        subject.project_type = pt
        expect(subject.project_protects_households?).to eq true
      end
    end
  end
end
