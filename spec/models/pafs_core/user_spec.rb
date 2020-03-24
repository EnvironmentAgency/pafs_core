# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::User, type: :model do
  describe "attributes" do
    subject { FactoryBot.create(:user) }

    it { is_expected.to validate_presence_of :first_name }

    it { is_expected.to validate_presence_of :last_name }

    # This gets handled by Devise in the front-end
    # if we include the validation at this level we get duplicate error messages
    # at the front-end
    # it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "#full_name" do
    subject { FactoryBot.build(:user) }
    it "returns :first_name and :last_name" do
      expect(subject.full_name).to eq("#{subject.first_name} #{subject.last_name}")
    end
  end

  describe "areas" do
    subject { FactoryBot.create(:user) }
    let(:primary_area) { FactoryBot.create(:rma_area, parent_id: 1) }
    let(:secondary_area) { FactoryBot.create(:rma_area, parent_id: 1) }
    let(:outside_area) { FactoryBot.create(:rma_area, parent_id: 1) }

    describe "#areas" do
      it "should return the correct areas" do
        PafsCore::UserArea.create(user: subject, area: primary_area, primary: true)
        PafsCore::UserArea.create(user: subject, area: secondary_area)

        expect(subject.areas).to include(primary_area, secondary_area)
        expect(subject.areas).to_not include(outside_area)
      end
    end

    describe "#primary_area" do
      it "should return the users primary_area" do
        PafsCore::UserArea.create(user: subject, area: primary_area, primary: true)
        PafsCore::UserArea.create(user: subject, area: secondary_area)

        expect(subject.primary_area).to eq(primary_area)
        expect(subject.primary_area).to_not eq(secondary_area)
      end
    end

    describe "#update_primary_area" do
      it "should update the users primary_area" do
        PafsCore::UserArea.create(user: subject, area: primary_area, primary: true)
        PafsCore::UserArea.create(user: subject, area: secondary_area)

        expect(subject.primary_area).to eq(primary_area)
        expect(subject.primary_area).to_not eq(secondary_area)

        subject.update_primary_area(secondary_area)

        expect(subject.primary_area).to eq(secondary_area)
        expect(subject.primary_area).to_not eq(primary_area)
      end
    end
  end
end
