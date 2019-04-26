# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
require "rails_helper"

RSpec.describe PafsCore::DataMigration::RemoveDuplicateStates do
  describe '#perform_all' do
    let!(:project_1) { create(:project) }
    let!(:project_2) { create(:project) }
    let(:deduplicator) { double(:deduplicator, perform: true) }

    it 'deduplicates all projects' do
      expect(described_class).to receive(:new).with(project_1).and_return(deduplicator)
      expect(described_class).to receive(:new).with(project_2).and_return(deduplicator)

      described_class.perform_all
    end
  end

  describe '#perform' do
    let!(:project) { create(:project, state: state) }
    let(:state) { create(:state, state: 'draft') }

    subject { described_class.new(project) }

    context 'without a duplicated status in the project' do
      it 'does not delete the state' do
        expect do
          subject.perform
        end.not_to change(PafsCore::State, :count)
      end
    end

    context 'with a duplicated status in the project' do
      before do
        PafsCore::State.create(project_id: project.id, state: :draft)
      end

      it 'removes the duplicate state' do
        expect do
          subject.perform
        end.to change(PafsCore::State, :count).by(-1)
      end

      it 'deleted the correct state' do
        subject.perform
        expect(project.reload.state.id).to eql(state.id)
      end
    end

    context 'with two different states in the project' do
      before do
        PafsCore::State.create(project_id: project.id, state: :archived)
      end

      it 'removes the duplicate state' do
        expect do
          subject.perform
        end.to change(PafsCore::State, :count).by(-1)
      end

      it 'deleted the correct state' do
        subject.perform
        expect(project.reload.state.id).to eql(state.id)
      end
    end

    context 'with more than two states in the project' do
      before do
        PafsCore::State.create(project_id: project.id, state: :archived)
        PafsCore::State.create(project_id: project.id, state: :submitted)
        PafsCore::State.create(project_id: project.id, state: :draft)
        PafsCore::State.create(project_id: project.id, state: :completed)
      end

      it 'removes the duplicate states' do
        expect do
          subject.perform
        end.to change(PafsCore::State, :count).by(-4)
      end

      it 'deleted the correct states' do
        subject.perform
        expect(project.reload.state.id).to eql(state.id)
      end
    end
  end
end
