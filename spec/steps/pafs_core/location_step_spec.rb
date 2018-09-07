# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

module PafsCore
  RSpec.describe PafsCore::LocationStep, type: :model do
    subject { described_class.new(project, user) }

    let(:grid_reference) { "ST 12345 67890" }
    let(:reference_number) { "WEX-0000-0000" }
    let(:project) do
      PafsCore::Project.new(
        {
          reference_number: reference_number,
          grid_reference: grid_reference
        }
      )
    end
    let(:user) { double(:user) }

    describe '#valid?' do
      context 'a valid grid reference' do
        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
    # describe "attributes" do
    #   subject { FactoryGirl.build(:location_step) }
    #
    #   it_behaves_like "a project step"
    # end

    # describe "#benefit_area" do
    #   subject { FactoryGirl.create(:location_step) }
    #
    #   context "with a defined benefit_area" do
    #     it "should return the benefit_area" do
    #       subject.project.benefit_area = "[[[457736,221754]]]"
    #       subject.project.save
    #
    #       expect(subject.benefit_area).to eq "[[[457736,221754]]]"
    #     end
    #   end
    #
    #   context "when benefit_area is nil" do
    #     it "should return \"[[[]]]\"" do
    #       expect(subject.benefit_area).to eq "[[[]]]"
    #     end
    #   end
    # end

    # describe "#update", :vcr do
    #   subject { FactoryGirl.create(:location_step) }
    #   let(:params) {
    #     HashWithIndifferentAccess.new({
    #       location_step: {
    #         project_location: "[\"457736\", \"221754\"]",
    #         project_location_zoom_level: 19
    #       }
    #     })
    #   }
    #   let(:error_params) {
    #     HashWithIndifferentAccess.new({
    #       location_step: {
    #         project_location: nil,
    #         project_location_zoom_level: nil
    #       }
    #     })
    #   }
    #
    #   it "saves the :project_location when valid" do
    #     expect(subject.project_location).not_to eq %w(457736 221754)
    #     expect(subject.project_location_zoom_level).not_to eq 19
    #     expect(subject.update(params)).to be true
    #     expect(subject.project_location).to eq %w(457736 221754)
    #     expect(subject.project_location_zoom_level).to eq 19
    #   end
    #
    #   it "returns false when validation fails" do
    #     expect(subject.update(error_params)).to eq false
    #   end
    # end
  end
end
