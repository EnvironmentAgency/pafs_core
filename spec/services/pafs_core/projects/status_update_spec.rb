# frozen_string_literal: true

require "rails_helper"

RSpec.describe PafsCore::Projects::StatusUpdate do
  describe 'with a valid new status' do
    STATUS_MAP = {
      'Draft': :draft,
      'Review': :completed,
      'Submitted': :submitted,
      'Archived': :archived
    }

    let(:project) { create(:project) }

    STATUS_MAP.each do |k, v|
      it "sets the status of the project to #{v} when given #{v}" do
        described_class.new(project, v).perform
        expect(project.reload.status).to eql(v)
      end

      it "sets the status of the project to #{v} when given #{k}" do
        described_class.new(project, k).perform
        expect(project.reload.status).to eql(v)
      end
    end

    it 'sets the project status to draft when an invalid status is received' do
      described_class.new(project, 'INVALID').perform
      expect(project.reload.status).to eql(:draft)
    end
  end
end

