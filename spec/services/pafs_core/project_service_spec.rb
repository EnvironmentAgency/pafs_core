# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProjectService do
  describe ".new_project" do
    it "builds a new project model without saving to the database" do
      p = nil
      expect { p = subject.new_project }.to_not change { PafsCore::Project.count }
      expect(p).to be_a PafsCore::Project
      expect(p.reference_number).to_not be_nil
      expect(p.version).to eq(1)
    end
  end

  describe ".create_project" do
    it "creates a new project and saves to the database" do
      p = nil
      expect { p = subject.create_project }.
        to change { PafsCore::Project.count }.by(1)

      expect(p).to be_a PafsCore::Project
      expect(p.reference_number).to_not be_nil
      expect(p.version).to eq(1)
    end
  end

  describe ".find_project" do
    it "finds a project in the database by reference number" do
      p = subject.create_project
      expect(subject.find_project(p.to_param)).to eq(p)
    end

    it "raises ActiveRecord::RecordNotFound for an invalid reference_number" do
      expect { subject.find_project("123") }.
        to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".generate_reference_number" do
    it "returns a reference number in the correct format" do
      PafsCore::RFCC_CODES.each do |rfcc_code|
        ref = subject.generate_reference_number(rfcc_code)
        expect(ref).to match /\A(AC|AE|AN|NO|NW|SN|SO|SW|TH|TR|WX|YO)C501E\/\d{3}A\/\d{3}A\z/
      end
    end
  end
end
