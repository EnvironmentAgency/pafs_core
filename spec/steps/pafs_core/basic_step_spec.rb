# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
require_relative "./shared_step_spec"

RSpec.describe PafsCore::BasicStep, type: :model do
  subject { FactoryGirl.build(:basic_step) }

  it_behaves_like "a project step"

  describe "#completed?" do
    it "returns true as there are no validations for a BasicStep" do
      expect(subject.completed?).to be true
    end
  end

  describe "#disabled?" do
    it "returns false as a default for the subclasses" do
      expect(subject.disabled?).to be false
    end
  end

  describe "#step_name" do
    it "returns the name representing the current step derived from the class name" do
      expect(subject.step_name).to eq("basic")
    end
  end

  describe "#view_path" do
    it "returns the name of the view file based on the step class name" do
      expect(subject.view_path).to eq "pafs_core/projects/steps/basic"
    end
  end
end
