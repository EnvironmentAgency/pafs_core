# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::Area, type: :model do
  context "Any Area" do
    describe "attributes" do
      area_levels = [
        {
          level: :country,
          parent_id: nil
        },
        {
          level: :ea_area,
          parent_id: 1
        },
        {
          level: :pso_area,
          parent_id: 1
        },
        {
          level: :rma_area,
          parent_id: 1
        },
      ]
      area = area_levels.sample
      subject { FactoryGirl.create(area[:level], parent_id: area[:parent_id]) }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :area_type }
      it { is_expected.to validate_inclusion_of(:area_type).in_array(PafsCore::Area::AREA_TYPES) }
    end
  end
  context "Country" do
    describe "attributes" do
      subject { FactoryGirl.create(:country) }

      it { is_expected.to_not validate_presence_of :parent_id }
    end
  end
  context "sub-Country area" do
    describe "attributes" do
      area_levels = [:ea_area, :pso_area, :rma_area]
      subject { FactoryGirl.create(area_levels.sample, parent_id: 1) }

      it { is_expected.to validate_presence_of :parent_id }
    end
  end
end
