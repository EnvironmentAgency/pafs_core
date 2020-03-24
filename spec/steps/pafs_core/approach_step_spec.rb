# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::ApproachStep, type: :model do
  subject { FactoryBot.build(:approach_step) }

  describe "attributes" do
    it_behaves_like "a project step"

    it "validates that :approach is present" do
      subject.approach = nil
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:approach]).to include
      "^Tell us the work the project plans to do to achieve its outcomes."
    end
  end

  describe "#update" do
    let(:params) do
      ActionController::Parameters.new({
                                      approach_step: {
                                        approach: "Wigwam on toast"
                                      }
                                    })
    end

    let(:error_params) do
      ActionController::Parameters.new({
                                      approach_step: {
                                        approach: ""
                                      }
                                    })
    end

    it "saves the :approach when valid" do
      expect(subject.approach).not_to eq "Wigwam on toast"
      expect(subject.update(params)).to be true
      expect(subject.approach).to eq "Wigwam on toast"
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
