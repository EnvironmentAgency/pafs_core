# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::AwardContractDateStep, type: :model do
  describe "attributes" do
    subject { FactoryBot.build(:award_contract_date_step) }

    it_behaves_like "a project step"
  end

  describe "#update" do
    let(:project) do
      FactoryBot.create(
        :project,
        start_outline_business_case_month: 1,
        start_outline_business_case_year: 2012
      )
    end

    subject { FactoryBot.create(:award_contract_date_step, project: project) }
    let(:params) do
      ActionController::Parameters.new({
                                         award_contract_date_step: {
                                           award_contract_case_year: "2020",
                                           award_contract_month: "1"
                                         }
                                       })
    end

    let(:invalid_month_params) do
      ActionController::Parameters.new({
                                         award_contract_date_step: {
                                           award_contract_month: "83",
                                           award_contract_year: "2020"
                                         }
                                       })
    end

    let(:invalid_year_params) do
      ActionController::Parameters.new({
                                         award_contract_date_step: {
                                           award_contract_month: "12",
                                           award_contract_year: "1999"
                                         }
                                       })
    end

    let(:invalid_date_params) do
      ActionController::Parameters.new({
                                         award_contract_date_step: {
                                           award_contract_month: "12",
                                           award_contract_year: "2011"
                                         }
                                       })
    end

    it "saves the start outline business case fields when valid" do
      %i[award_contract_month award_contract_year].each do |attr|
        new_val = subject.send(attr) + 1
        params = ActionController::Parameters.new(award_contract_date_step: { attr => new_val })
        expect(subject.update(params)).to be true
        expect(subject.send(attr)).to eq new_val
      end
    end

    it "returns false when validation fails" do
      expect(subject.update(invalid_month_params)).to eq false
      expect(subject.update(invalid_year_params)).to eq false
      expect(subject.update(invalid_date_params)).to eq false
    end
  end
end
