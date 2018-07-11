# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::ProjectAreaStep, type: :model do
  subject { FactoryGirl.build(:project_area_step, rma_name: 'PSO Wessex') }

  describe '#attributes' do
    it_behaves_like "a project step"

    it 'has a RMA name' do
      expect(subject.rma_name).to eql('PSO Wessex')
    end
  end

  describe '#valid?' do

    context 'RMA name not set' do
      subject { FactoryGirl.build(:project_area_step, rma_name: nil) }

      it 'must have a RMA name' do
        expect(subject).not_to be_valid
      end

      it 'displays the expected validation message' do
        subject.valid?

        expect(subject.errors.messages[:rma_name]).to include("^Select a lead PSO area")
      end
    end
  end
end
