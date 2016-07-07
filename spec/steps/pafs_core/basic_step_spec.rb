# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
#require_relative "./shared_step_spec"

RSpec.describe PafsCore::BasicStep, type: :model do
  subject { FactoryGirl.build(:basic_step) }

  it_behaves_like "a project step"

  describe "#completed?" do
    it "returns true as there are no validations for a BasicStep" do
      expect(subject.completed?).to eq true
    end
  end

  describe "#incomplete?" do
    it "returns the inverse of #completed?" do
      expect(subject.incomplete?).to eq !subject.completed?
    end
  end

  describe "#disabled?" do
    it "returns false as a default for the subclasses" do
      expect(subject.disabled?).to eq false
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

  describe "#is_current_step?" do
    it "returns true if the current step matches the step parameter" do
      expect(subject.is_current_step?(:basic)).to eq true
    end

    it "returns false if the current step does not match the step parameter" do
      expect(subject.is_current_step?(:not_this_step)).to eq false
    end
  end

  describe "#save!" do
    subject { FactoryGirl.build(:basic_step) }

    it "saves the record when validations passed" do
      expect { subject.save! }.to change { PafsCore::Project.count }
    end

    it "raises ActiveRecord::RecordInvalid when validation fails" do
      subject.project.reference_number = nil
      expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
