# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::ProjectNameStep, type: :model do
  describe "attributes" do
    subject { FactoryGirl.build(:project_name_step) }

    it_behaves_like "a project step"

    it { is_expected.to validate_presence_of :name }
  end

  describe "#update" do
    subject { FactoryGirl.create(:project_name_step) }
    let(:params) { HashWithIndifferentAccess.new({ project_name_step: { name: "Wigwam waste water" }})}
    let(:error_params) { HashWithIndifferentAccess.new({ project_name_step: { name: nil }})}

    it "saves the :name when valid" do
      expect(subject.name).not_to eq "Wigwam waste water"
      expect(subject.update(params)).to be true
      expect(subject.name).to eq "Wigwam waste water"
    end

    it "updates the next step if valid" do
      expect(subject.step).to eq :project_name
      subject.update(params)
      expect(subject.step).to eq :project_type
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end

    it "does not change the next step when validation fails" do
      expect(subject.step).to eq :project_name
      subject.update(error_params)
      expect(subject.step).to eq :project_name
    end
  end

  describe "#previous_step" do
    subject { FactoryGirl.build(:project_name_step) }

    it "should return ProjectNavigator.first_step" do
      expect(subject.previous_step).to eq PafsCore::ProjectNavigator.first_step
    end
  end
end
