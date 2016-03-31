# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
require_relative "./shared_step_spec"

RSpec.describe PafsCore::ProjectNameStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:project_name_step) }

    it_behaves_like "a project step"

    it { is_expected.to validate_presence_of :name }
  end
end
