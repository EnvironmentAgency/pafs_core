# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

require "rails_helper"
# require_relative "./shared_step_spec"

RSpec.describe PafsCore::MainRiskStep, type: :model do
  before(:each) do
    @project = FactoryBot.build(:main_risk_step)
    # required to be valid
    @project.project.update_attributes(groundwater_flooding: true)
    @project.project.save
  end
  subject { @project }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that at a main risk source is selected" do
      subject.main_risk = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:main_risk]).to include "^Select the main risk the project protects against."
    end

    it "validates that the main risk source is one of the selected risks" do
      subject.project.tidal_flooding = true
      subject.project.fluvial_flooding = false
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:main_risk]).to include "must be one of the selected risks"
    end
  end

  describe "#update" do
    context "a project that does protect households" do
      context "protecting against flooding" do
        let(:params) do
          ActionController::Parameters.new({
                                          main_risk_step: {
                                            main_risk: "groundwater_flooding"
                                          }
                                        })
        end
        let(:error_params) do
          ActionController::Parameters.new({
                                          main_risk_step: {
                                            main_risk: nil
                                          }
                                        })
        end

        it "saves the state of valid params" do
          expect(subject.update(params)).to be true
          expect(subject.main_risk).to eq "groundwater_flooding"
        end

        it "returns false when validation fails" do
          expect(subject.update(error_params)).to eq false
        end
      end
      context "protecting against coastal erosion" do
        before(:each) do
          @project.project.update_attributes(groundwater_flooding: false, coastal_erosion: true)
        end

        let(:params) do
          ActionController::Parameters.new({
                                          main_risk_step: {
                                            main_risk: "coastal_erosion"
                                          }
                                        })
        end
        it "saves the state of valid params" do
          expect(subject.update(params)).to be true
          expect(subject.main_risk).to eq "coastal_erosion"
        end
      end
    end
  end

  describe "#selected_risks" do
    it "returns a list of selected risks" do
      expect(subject.selected_risks.count).to eq 1
    end
  end
end
