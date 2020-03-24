# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::StartOutlineBusinessCaseDateStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:start_outline_business_case_date_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    subject { FactoryBot.create(:start_outline_business_case_date_step) }
    let(:params) do
      ActionController::Parameters.new({
                                      start_outline_business_case_date_step: {
                                        start_outline_business_case_year: "2020"
                                      }
                                    })
    end

    let(:error_params) do
      ActionController::Parameters.new({
                                      start_outline_business_case_date_step: {
                                        start_outline_business_case_month: "83"
                                      }
                                    })
    end

    it "saves the start outline business case fields when valid" do
      %i[start_outline_business_case_month start_outline_business_case_year].each do |attr|
        new_val = subject.send(attr) + 1
        params = ActionController::Parameters.new(start_outline_business_case_date_step: { attr => new_val })
        expect(subject.update(params)).to be true
        expect(subject.send(attr)).to eq new_val
      end
    end

    it "returns false when validation fails" do
      expect(subject.update(error_params)).to eq false
    end
  end
end
