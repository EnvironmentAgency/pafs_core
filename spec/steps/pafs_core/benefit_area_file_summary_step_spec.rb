# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::BenefitAreaFileSummaryStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:benefit_area_file_summary_step) }

    it_behaves_like "a project step"
  end
end
