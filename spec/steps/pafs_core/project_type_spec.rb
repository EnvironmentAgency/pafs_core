# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::ProjectTypeStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:project_type_step) }

    it_behaves_like "a project step"

    it "validates that :project_type is present" do
      subject.project_type = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:project_type]).to include "^Select a project type"
    end

    it "validates that the selected :project_type is valid" do
      PafsCore::PROJECT_TYPES.reject { |t| t == "ENV" }.each do |pt|
        subject.project_type = pt
        expect(subject.valid?).to be true
      end
      subject.project_type = "Peanuts"
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:project_type]).to include "^Select a project type"
    end
  end

  describe "#update" do
    subject { FactoryBot.create(:project_type_step) }
    let(:params) { ActionController::Parameters.new({ project_type_step: { project_type: "STR" } }) }
    let(:error_params) { ActionController::Parameters.new({ project_type_step: { project_type: "ABC" } }) }

    it "saves the :project_type when valid" do
      expect(subject.project_type).not_to eq "STR"
      expect(subject.update(params)).to be true
      expect(subject.project_type).to eq "STR"
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
