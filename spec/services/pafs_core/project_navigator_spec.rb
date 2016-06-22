# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProjectNavigator do
  before(:each) do
    @pso = FactoryGirl.create(:pso_area, parent_id: 1, name: "PSO Essex")
    @rma = FactoryGirl.create(:rma_area, parent_id: @pso.id)
    @user = FactoryGirl.create(:user)
    @user.user_areas.create(area_id: @rma.id, primary: true)
  end
  subject { PafsCore::ProjectNavigator.new @user }

  describe ".first_step" do
    it "returns the identifier of first step in the journey" do
      expect(described_class.first_step).to eq(described_class::STEPS.first)
    end
  end

  describe ".last_step" do
    it "returns the identifier of last step in the journey" do
      expect(described_class.last_step).to eq(described_class::STEPS.last)
    end
  end

  describe "#start_new_project" do
    it "creates a new project wrapped in the first step of the process" do
      p = nil
      expect { p = subject.start_new_project }.to change { PafsCore::Project.count }.by(1)
      expect(p).to respond_to :reference_number
    end
  end

  describe "#find_project_step" do
    let(:project) { subject.start_new_project }
    it "finds a project by :reference_number wrapped in the requested :step of the process" do
      p = subject.find_project_step(project.to_param, described_class.last_step)
      expect(p).to respond_to :reference_number
      expect(p.step).to eq(described_class.last_step)
    end

    it "raises ActiveRecord::RecordNotFound for an invalid :reference_number" do
      expect { subject.find_project_step("123", described_class.last_step) }.
        to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises ActiveRecord::RecordNotFound for an invalid :step" do
      expect { subject.find_project_step(project, :wigwam) }.
        to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".build_project_step" do
    let(:raw_project) { FactoryGirl.build(:project) }
    let(:project_step) { subject.start_new_project }
    let(:user) { FactoryGirl.build(:user) }

    it "wraps a project record with the requested :step" do
      expect(raw_project).to be_a PafsCore::Project
      p = described_class.build_project_step(raw_project, described_class.first_step, user)
      expect(p).to be_a PafsCore::BasicStep
      expect(p.step).to eq(described_class.first_step)
    end

    it "re-wraps an existing project step with the requested :step" do
      expect(project_step.step).to eq(described_class.first_step)
      p = described_class.build_project_step(project_step, described_class.last_step, user)
      expect(p.step).to eq(described_class.last_step)
    end
  end
end
