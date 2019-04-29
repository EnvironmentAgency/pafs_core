# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::KeyDatesStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:key_dates_step) }

    it_behaves_like "a project step"
  end
end
