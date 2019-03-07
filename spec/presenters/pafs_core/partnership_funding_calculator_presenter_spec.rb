require "rails_helper"

RSpec.describe PafsCore::PartnershipFundingCalculatorPresenter do
  subject { described_class.new(project: project) }

  let(:project) do
    FactoryGirl.create(:full_project, funding_calculator_file_name: calculator_file)
  end

  let(:calculator_file) do
    "calculator.xlsx"
  end

  before(:each) do
    allow_any_instance_of(PafsCore::Files)
      .to receive(:fetch_funding_calculator_for)
      .with(project)
      .and_return(File.open(File.join(Rails.root, '..', 'fixtures', calculator_file)))
  end

  describe "#attributes" do
    it "includes pv_appraisal_approach" do
      expect(subject.attributes[:pv_appraisal_approach]).to eql(12345)
    end
  end
end
