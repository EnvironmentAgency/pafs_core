# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.shared_examples "a project step" do
  describe "attributes" do
    it "encapsulates a :project" do
      expect(subject).to respond_to :project
    end

    it "can read :id" do
      expect(subject).to respond_to :id
    end

    it "can read :reference_number" do
      expect(subject).to respond_to :reference_number
    end

    it "returns parameterized :reference_number as a URL slug" do
      expect(subject.to_param).to eq(subject.reference_number.parameterize.upcase)
    end

    it "responds to :persisted?" do
      expect(subject).to respond_to :persisted?
    end

    it "responds to :completed?" do
      expect(subject).to respond_to :completed?
    end

    it "responds to :disabled?" do
      expect(subject).to respond_to :disabled?
    end
  end
end
