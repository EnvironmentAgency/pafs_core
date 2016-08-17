# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::MapService do
  subject { PafsCore::MapService.new }

  describe "#find" do
    let(:project) { FactoryGirl.create(:location_step) }
    it "should return a valid result" do
      result = subject.find("", project.project_location)
      expect(result).to eq([{eastings: "404040", northings: "212121"}])
    end
  end
end
