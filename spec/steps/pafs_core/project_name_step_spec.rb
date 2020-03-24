# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ProjectNameStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:project_name_step) }

    it_behaves_like "a project step"

    it { is_expected.to validate_presence_of(:name).with_message("^Tell us the project name") }
  end

  describe "#update" do
    subject { FactoryBot.create(:project_name_step) }
    let(:params) { ActionController::Parameters.new({ project_name_step: { name: "Wigwam waste water" } }) }
    let(:error_params) { ActionController::Parameters.new({ project_name_step: { name: nil } }) }

    it "saves the :name when valid" do
      expect(subject.name).not_to eq "Wigwam waste water"
      expect(subject.update(params)).to be true
      expect(subject.name).to eq "Wigwam waste water"
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
