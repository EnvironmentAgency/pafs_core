# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::ProjectTypeStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:project_type_step) }

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
    context "when ENV is the selected :project_type" do
      before(:each) { subject.project_type = "ENV" }

      it "validates that :environmental_type is present" do
        expect(subject.valid?).to be false
        expect(subject.errors.messages[:environmental_type]).to include "^Select an environmental type"
      end
      it "validates that :environmental_type is a permitted value" do
        PafsCore::ENVIRONMENTAL_TYPES.each do |et|
          subject.environmental_type = et
          expect(subject.valid?).to be true
        end
        subject.environmental_type = "BANANA"
        expect(subject.valid?).to be false
        expect(subject.errors.messages[:environmental_type]).to include "^Select an environmental type"
      end
    end
    context "when ENV is not the selected :project_type" do
      it "removes :environmental_type" do
        PafsCore::PROJECT_TYPES.reject { |t| t == "ENV" }.each do |pt|
          subject.environmental_type = PafsCore::ENVIRONMENTAL_TYPES.first
          expect {
            subject.update({ project_type_step: { project_type: pt } })
          }.to change { subject.environmental_type }.to nil
          expect(subject.valid?).to eq true
        end
      end
    end
  end

  describe "#update" do
    subject { FactoryGirl.create(:project_type_step) }
    let(:params) { HashWithIndifferentAccess.new({ project_type_step: { project_type: "STR" }})}
    let(:error_params) { HashWithIndifferentAccess.new({ project_type_step: { project_type: "ABC" }})}

    it "saves the :project_type when valid" do
      expect(subject.project_type).not_to eq "STR"
      expect(subject.update(params)).to be true
      expect(subject.project_type).to eq "STR"
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :project_type
      subject.update(params)
      expect(subject.step).to eq :financial_year
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :project_type
      subject.update(error_params)
      expect(subject.step).to eq :project_type
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:project_type_step) }

    it "should return :project_name" do
      expect(subject.previous_step).to eq :project_name
    end
  end
end
