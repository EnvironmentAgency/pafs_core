# frozen_string_literal: true

module PafsCore
  module DataMigration
    class RemoveDuplicateStates
      def self.perform_all
        PafsCore::Project.find_each do |project|
          new(project).perform
        end
      end

      attr_reader :project

      def initialize(project)
        @project = project
      end

      def states
        @states ||= PafsCore::State.where(project_id: project.id)
      end

      def has_duplicate_state?
        states.size > 1
      end

      def duplicate_states
        @duplicate_states ||= states.reject do |state|
          state.id == project.state.id
        end
      end

      def perform
        return unless has_duplicate_state?

        duplicate_states.map(&:destroy)
      end
    end
  end
end
