# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::SpreadsheetPresenter do
  subject { described_class.new(project) }

  describe "moderation_code" do
    context 'with an urgent project' do
      let(:project) { build(:project, urgency_reason: :legal_need) }

      it 'returns the correct moderation code' do
        expect(subject.moderation_code).to eql("Legal Agreement")
      end
    end

    context  'with a non urgent project' do
      let(:project) { build(:project, urgency_reason: :not_urgent) }

      it 'returns "Not Urgent"' do
        expect(subject.moderation_code).to eql("Not Urgent")
      end
    end
  end
end

